// @ts-nocheck
// herdr-hunk-review: when pi finishes a turn that changed a git-tracked repo,
// record it for the current herdr pane/tab and announce that review is ready.
// Live Hunk sessions are refreshed and de-duplicated by repository.
//
// This is a hand-authored sibling of herdr's managed integration
// (herdr-agent-state.ts). Herdr does NOT manage or overwrite this file.

import { spawn } from "node:child_process";
import { mkdirSync, readdirSync, realpathSync, renameSync, statSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { basename, dirname, join } from "node:path";

const HERDR_ENV = process.env.HERDR_ENV;
const workspaceId = process.env.HERDR_WORKSPACE_ID;
const tabId = process.env.HERDR_TAB_ID;
const paneId = process.env.HERDR_PANE_ID;
const mode = process.env.HERDR_HUNK_MODE ?? "manual-overlay";
const disabled = process.env.HERDR_HUNK_DISABLE === "1" || mode === "off";

const labelPrefix = process.env.HERDR_HUNK_LABEL_PREFIX ?? "🔍 hunk: ";
const useWatch = process.env.HERDR_HUNK_WATCH !== "0";
const focusFlag = process.env.HERDR_HUNK_FOCUS === "1" ? "--focus" : "--no-focus";
const openHint = process.env.HERDR_HUNK_OPEN_HINT ?? "Ctrl+Space then D";
const stateDir =
  process.env.HERDR_HUNK_STATE_DIR ??
  join(process.env.XDG_STATE_HOME ?? join(homedir(), ".local", "state"), "herdr-hunk-review");
const configuredTtlDays = Number.parseInt(process.env.HERDR_HUNK_STATE_TTL_DAYS ?? "30", 10);
const stateTtlMs = (Number.isFinite(configuredTtlDays) && configuredTtlDays > 0 ? configuredTtlDays : 30) * 86_400_000;

const EDIT_TOOLS = new Set(["edit", "write", "multiedit", "multi_edit", "apply_patch"]);

function herdrActive(): boolean {
  return !disabled && HERDR_ENV === "1" && !!workspaceId;
}

type RunResult = { code: number; stdout: string; stderr: string };

function run(cmd: string, args: string[], opts: { timeoutMs?: number; cwd?: string } = {}): Promise<RunResult> {
  const timeoutMs = opts.timeoutMs ?? 6000;
  return new Promise((resolve) => {
    let stdout = "";
    let stderr = "";
    let done = false;
    let timer: ReturnType<typeof setTimeout> | undefined;
    const finish = (code: number) => {
      if (done) return;
      done = true;
      if (timer) clearTimeout(timer);
      resolve({ code, stdout, stderr });
    };
    let child: ReturnType<typeof spawn>;
    try {
      child = spawn(cmd, args, { cwd: opts.cwd, stdio: ["ignore", "pipe", "pipe"] });
    } catch {
      finish(-1);
      return;
    }
    timer = setTimeout(() => {
      try {
        child.kill("SIGKILL");
      } catch {}
      finish(-1);
    }, timeoutMs);
    timer.unref?.();
    child.stdout?.on("data", (d) => {
      stdout += d.toString();
    });
    child.stderr?.on("data", (d) => {
      stderr += d.toString();
    });
    child.on("error", () => finish(-1));
    child.on("close", (code) => finish(code ?? -1));
  });
}

function canonical(p: string | undefined | null): string | null {
  if (!p) return null;
  try {
    return realpathSync(p);
  } catch {
    return p;
  }
}

function stateKey(id: string): string {
  return id.replace(/[^A-Za-z0-9._-]/gu, "_");
}

function pruneReviewState(): void {
  const cutoff = Date.now() - stateTtlMs;
  for (const kind of ["pane", "tab", "overlay"]) {
    const dir = join(stateDir, kind);
    try {
      for (const file of readdirSync(dir)) {
        const path = join(dir, file);
        if (statSync(path).mtimeMs < cutoff) unlinkSync(path);
      }
    } catch {}
  }
}

function writeReviewState(kind: "pane" | "tab", id: string | undefined, repo: string): void {
  if (!id) return;
  try {
    const dir = join(stateDir, kind);
    mkdirSync(dir, { recursive: true });
    const target = join(dir, `${stateKey(id)}.json`);
    const temp = `${target}.${process.pid}.${Date.now()}.tmp`;
    writeFileSync(temp, `${JSON.stringify({ version: 1, repo })}\n`, { encoding: "utf8", mode: 0o600 });
    renameSync(temp, target);
  } catch (error) {
    console.error(`herdr-hunk-review: failed to record ${kind} review state`, error);
  }
}

function rememberReview(repo: string): void {
  writeReviewState("pane", paneId, repo);
  writeReviewState("tab", tabId, repo);
}

async function repoRoot(filePath: string): Promise<string | null> {
  const dir = dirname(filePath);
  const res = await run("git", ["-C", dir, "rev-parse", "--show-toplevel"], { timeoutMs: 4000 });
  if (res.code !== 0) return null;
  const root = res.stdout.trim();
  return root ? canonical(root) : null;
}

async function hasChanges(repo: string): Promise<boolean> {
  const res = await run("git", ["-C", repo, "status", "--porcelain"], { timeoutMs: 4000 });
  if (res.code !== 0) return false;
  return res.stdout.trim().length > 0;
}

function firstString(obj: any, keys: string[]): string | undefined {
  if (!obj || typeof obj !== "object") return undefined;
  for (const k of keys) {
    const v = obj[k];
    if (typeof v === "string" && v.length > 0) return v;
  }
  return undefined;
}

// Match a live Hunk session to a repo root using the daemon's session list.
async function findSessionForRepo(repo: string): Promise<boolean> {
  const res = await run("hunk", ["session", "list", "--json"], { timeoutMs: 5000 });
  if (res.code !== 0 || !res.stdout.trim()) return false;
  let parsed: any;
  try {
    parsed = JSON.parse(res.stdout);
  } catch {
    return false;
  }
  const sessions: any[] = Array.isArray(parsed) ? parsed : parsed?.sessions ?? parsed?.result?.sessions ?? [];
  const target = canonical(repo);
  for (const s of sessions) {
    const repoVal = firstString(s, ["repo", "Repo", "repoRoot", "root"]);
    const pathVal = firstString(s, ["path", "Path", "cwd"]);
    if ((repoVal && canonical(repoVal) === target) || (pathVal && canonical(pathVal) === target)) {
      return true;
    }
  }
  return false;
}

async function paneIdForTab(tabId: string): Promise<string | null> {
  const get = await run("herdr", ["tab", "get", tabId], { timeoutMs: 5000 });
  if (get.code === 0 && get.stdout.trim()) {
    try {
      const parsed = JSON.parse(get.stdout);
      const result = parsed?.result ?? parsed;
      const tab = result?.tab ?? result;
      const panes: any[] = tab?.panes ?? result?.panes ?? [];
      const paneId = firstString(panes[0], ["pane_id", "id"]) ?? firstString(result, ["pane_id"]);
      if (paneId) return paneId;
    } catch {}
  }
  // Fallback: scan the workspace pane list for one belonging to this tab.
  const list = await run("herdr", ["pane", "list", "--workspace", workspaceId!], { timeoutMs: 5000 });
  if (list.code === 0 && list.stdout.trim()) {
    try {
      const parsed = JSON.parse(list.stdout);
      const panes: any[] = parsed?.result?.panes ?? parsed?.panes ?? [];
      const match = panes.find((p) => firstString(p, ["tab_id"]) === tabId);
      const paneId = firstString(match, ["pane_id", "id"]);
      if (paneId) return paneId;
    } catch {}
  }
  return null;
}

const opened = new Map<string, { tabId: string }>();

async function tabAlive(tabId: string): Promise<boolean> {
  const res = await run("herdr", ["tab", "get", tabId], { timeoutMs: 4000 });
  return res.code === 0;
}

async function openHunkTab(repo: string): Promise<void> {
  const label = `${labelPrefix}${basename(repo)}`;
  const create = await run(
    "herdr",
    ["tab", "create", "--workspace", workspaceId!, "--cwd", repo, "--label", label, focusFlag],
    { timeoutMs: 6000 },
  );
  if (create.code !== 0 || !create.stdout.trim()) return;
  let createdTabId: string | undefined;
  let createdPaneId: string | undefined;
  try {
    const parsed = JSON.parse(create.stdout);
    const result = parsed?.result ?? parsed;
    // `tab create` returns the new tab's default pane directly.
    createdPaneId = firstString(result?.root_pane, ["pane_id", "id"]);
    createdTabId =
      firstString(result?.tab, ["tab_id", "id"]) ??
      firstString(result?.root_pane, ["tab_id"]) ??
      firstString(result, ["tab_id"]);
  } catch {}
  if (!createdTabId) return;
  if (!createdPaneId) createdPaneId = (await paneIdForTab(createdTabId)) ?? undefined;
  if (!createdPaneId) return;
  const cmd = useWatch ? "hunk diff --watch" : "hunk diff";
  await run("herdr", ["pane", "run", createdPaneId, cmd], { timeoutMs: 5000 });
  opened.set(repo, { tabId: createdTabId });
}

async function reconcile(repo: string): Promise<boolean> {
  if (!(await hasChanges(repo))) return false;
  rememberReview(repo);
  if (await findSessionForRepo(repo)) {
    await run("hunk", ["session", "reload", "--repo", repo, "--", "diff"], { timeoutMs: 6000 });
    return true;
  }
  if (mode !== "auto-tab") return true;
  const prior = opened.get(repo);
  if (prior && (await tabAlive(prior.tabId))) {
    return true;
  }
  if (prior) opened.delete(repo);
  if (await findSessionForRepo(repo)) return true;
  await openHunkTab(repo);
  return true;
}

async function notifyReady(repos: string[]): Promise<void> {
  const latest = basename(repos[repos.length - 1]);
  const body =
    repos.length === 1
      ? `${latest} · ${openHint}`
      : `${repos.length} repositories ready; latest: ${latest} · ${openHint}`;
  const result = await run(
    "herdr",
    ["notification", "show", "Hunk review ready", "--body", body, "--sound", "none"],
    { timeoutMs: 4000 },
  );
  if (result.code !== 0) console.error("herdr-hunk-review: failed to show review notification", result.stderr);
}

export default function (pi: any) {
  // Contribute the current Hunk review skill whenever hunk is installed,
  // regardless of herdr, so pi can drive a live session.
  pi.on("resources_discover", async () => {
    const res = await run("hunk", ["skill", "path"], { timeoutMs: 4000 });
    if (res.code !== 0) return;
    const skillFile = res.stdout.trim();
    if (!skillFile) return;
    return { skillPaths: [dirname(skillFile)] };
  });

  if (!herdrActive()) return;
  pruneReviewState();

  const pendingPaths = new Map<string, string>();
  const dirtyRepos = new Set<string>();
  let busy = false;

  pi.on("tool_execution_start", (event: any) => {
    if (!EDIT_TOOLS.has(event?.toolName)) return;
    const p = firstString(event?.args, ["path", "file_path", "filePath"]);
    if (p) pendingPaths.set(event.toolCallId, p);
  });

  pi.on("tool_execution_end", async (event: any) => {
    const p = pendingPaths.get(event?.toolCallId);
    if (!p) return;
    pendingPaths.delete(event.toolCallId);
    if (event?.isError) return;
    const root = await repoRoot(p);
    if (root) dirtyRepos.add(root);
  });

  pi.on("agent_settled", async () => {
    if (busy || dirtyRepos.size === 0) return;
    busy = true;
    try {
      while (dirtyRepos.size > 0) {
        const repos = [...dirtyRepos];
        dirtyRepos.clear();
        const ready: string[] = [];
        for (const repo of repos) {
          try {
            if (await reconcile(repo)) ready.push(repo);
          } catch {}
        }
        if (mode !== "auto-tab" && ready.length > 0) await notifyReady(ready);
      }
    } finally {
      busy = false;
    }
  });
}
