// @ts-nocheck
// herdr-hunk-review: when pi finishes a turn that changed a git-tracked repo,
// open (or refresh) a Hunk review in a dedicated tab in the current herdr
// workspace. De-dupes via the Hunk daemon's live-session list, so it never
// spawns a second tab for a repo already under review.
//
// This is a hand-authored sibling of herdr's managed integration
// (herdr-agent-state.ts). Herdr does NOT manage or overwrite this file.

import { spawn } from "node:child_process";
import { dirname, basename } from "node:path";
import { realpathSync } from "node:fs";

const HERDR_ENV = process.env.HERDR_ENV;
const workspaceId = process.env.HERDR_WORKSPACE_ID;
const disabled = process.env.HERDR_HUNK_DISABLE === "1";

const labelPrefix = process.env.HERDR_HUNK_LABEL_PREFIX ?? "🔍 hunk: ";
const useWatch = process.env.HERDR_HUNK_WATCH !== "0";
const focusFlag = process.env.HERDR_HUNK_FOCUS === "1" ? "--focus" : "--no-focus";

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
    const timer = setTimeout(() => {
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

const opened = new Map<string, { tabId: string; ts: number }>();

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
  let tabId: string | undefined;
  let paneId: string | undefined;
  try {
    const parsed = JSON.parse(create.stdout);
    const result = parsed?.result ?? parsed;
    // `tab create` returns the new tab's default pane directly.
    paneId = firstString(result?.root_pane, ["pane_id", "id"]);
    tabId =
      firstString(result?.tab, ["tab_id", "id"]) ??
      firstString(result?.root_pane, ["tab_id"]) ??
      firstString(result, ["tab_id"]);
  } catch {}
  if (!tabId) return;
  if (!paneId) paneId = (await paneIdForTab(tabId)) ?? undefined;
  if (!paneId) return;
  const cmd = useWatch ? "hunk diff --watch" : "hunk diff";
  await run("herdr", ["pane", "run", paneId, cmd], { timeoutMs: 5000 });
  opened.set(repo, { tabId, ts: Date.now() });
}

async function reconcile(repo: string): Promise<void> {
  if (!(await hasChanges(repo))) return;
  if (await findSessionForRepo(repo)) {
    await run("hunk", ["session", "reload", "--repo", repo, "--", "diff"], { timeoutMs: 6000 });
    return;
  }
  const prior = opened.get(repo);
  if (prior && (await tabAlive(prior.tabId))) {
    // Tab is launching hunk (session not registered yet); --watch will refresh.
    return;
  }
  if (prior) opened.delete(repo);
  await openHunkTab(repo);
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
    const repos = [...dirtyRepos];
    dirtyRepos.clear();
    try {
      for (const repo of repos) {
        try {
          await reconcile(repo);
        } catch {}
      }
    } finally {
      busy = false;
    }
  });
}
