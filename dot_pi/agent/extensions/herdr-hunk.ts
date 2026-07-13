// @ts-nocheck
// herdr-hunk: when pi finishes a turn that changed a git-tracked repo,
// record it for the current herdr pane/tab and announce that review is ready.
// Live Hunk sessions are refreshed and de-duplicated by repository.
//
// This is a hand-authored sibling of herdr's managed integration
// (herdr-agent-state.ts). Herdr does NOT manage or overwrite this file.

import { spawn } from "node:child_process";
import { randomBytes } from "node:crypto";
import {
  chmodSync,
  lstatSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  realpathSync,
  renameSync,
  statSync,
  unlinkSync,
  writeFileSync,
} from "node:fs";
import { createServer } from "node:http";
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
const configuredMaxSubmissionBytes = Number.parseInt(
  process.env.HERDR_HUNK_MAX_SUBMISSION_BYTES ?? "262144",
  10,
);
const maxSubmissionBytes =
  Number.isFinite(configuredMaxSubmissionBytes) && configuredMaxSubmissionBytes > 0
    ? configuredMaxSubmissionBytes
    : 262144;

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

type ReceiverRegistration = {
  version: 1;
  pane_id: string;
  session_id: string;
  nonce: string;
  socket_path: string;
  pid: number;
};

type ReceiverRuntime = {
  server: ReturnType<typeof createServer>;
  registration: ReceiverRegistration;
  registrationPath: string;
};

function isRecord(value: unknown): value is Record<string, any> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function ensurePrivateDirectory(path: string): void {
  mkdirSync(path, { recursive: true, mode: 0o700 });
  const info = lstatSync(path);
  if (!info.isDirectory() || info.isSymbolicLink()) throw new Error(`${path} is not a safe directory`);
  chmodSync(path, 0o700);
}

function atomicWriteJson(target: string, value: unknown): void {
  ensurePrivateDirectory(dirname(target));
  const temp = `${target}.${process.pid}.${Date.now()}.${randomBytes(4).toString("hex")}.tmp`;
  try {
    writeFileSync(temp, `${JSON.stringify(value)}\n`, { encoding: "utf8", mode: 0o600, flag: "wx" });
    renameSync(temp, target);
  } catch (error) {
    try {
      unlinkSync(temp);
    } catch {}
    throw error;
  }
}

function receiverRegistrationPath(): string | null {
  return paneId ? join(stateDir, "receiver", `${stateKey(paneId)}.json`) : null;
}

function readRequestBody(request: any): Promise<string> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    let bytes = 0;
    let settled = false;
    request.on("data", (chunk: Buffer) => {
      if (settled) return;
      bytes += chunk.length;
      if (bytes > maxSubmissionBytes) {
        settled = true;
        request.pause();
        reject(Object.assign(new Error("Submission exceeds the size limit"), { status: 413 }));
        return;
      }
      chunks.push(chunk);
    });
    request.on("end", () => {
      if (settled) return;
      settled = true;
      resolve(Buffer.concat(chunks).toString("utf8"));
    });
    request.on("error", (error: Error) => {
      if (settled) return;
      settled = true;
      reject(error);
    });
  });
}

function sendJson(response: any, status: number, value: unknown): void {
  response.writeHead(status, { "content-type": "application/json", connection: "close" });
  response.end(`${JSON.stringify(value)}\n`);
}

function validateSubmission(payload: unknown, receiver: ReceiverRegistration): any {
  if (!isRecord(payload) || payload.version !== 1) throw new Error("Unsupported submission version");
  if (typeof payload.submission_id !== "string" || !/^[A-Za-z0-9._-]{1,128}$/.test(payload.submission_id)) {
    throw new Error("Invalid submission id");
  }
  if (!isRecord(payload.receiver)) throw new Error("Missing receiver identity");
  for (const key of ["pane_id", "session_id", "nonce", "socket_path"]) {
    if (payload.receiver[key] !== receiver[key]) throw new Error("Receiver identity does not match");
  }
  if (typeof payload.repo !== "string" || payload.repo.length === 0 || payload.repo.length > 4096) {
    throw new Error("Invalid repository path");
  }
  if (
    typeof payload.hunk_pane_id !== "string" ||
    payload.hunk_pane_id.length === 0 ||
    payload.hunk_pane_id.length > 256 ||
    typeof payload.hunk_session_id !== "string" ||
    payload.hunk_session_id.length === 0 ||
    payload.hunk_session_id.length > 256
  ) {
    throw new Error("Missing Hunk session identity");
  }
  if (!Array.isArray(payload.comments) || payload.comments.length === 0 || payload.comments.length > 100) {
    throw new Error("Expected between 1 and 100 comments");
  }
  for (const comment of payload.comments) {
    if (!isRecord(comment) || comment.source !== "user") throw new Error("Invalid user comment");
    if (typeof comment.noteId !== "string" || comment.noteId.length > 256) throw new Error("Invalid comment id");
    if (
      typeof comment.filePath !== "string" ||
      comment.filePath.length === 0 ||
      comment.filePath.length > 4096 ||
      comment.filePath.startsWith("/") ||
      comment.filePath.split("/").includes("..") ||
      comment.filePath.includes("\0")
    ) {
      throw new Error("Invalid comment path");
    }
    if (typeof comment.body !== "string" || comment.body.length === 0 || comment.body.length > 8192) {
      throw new Error("Invalid comment body");
    }
  }
  return payload;
}

function formatSubmittedComments(payload: any): string {
  const lines: string[] = [];
  for (const comment of payload.comments) {
    const line = comment.newRange?.[0] ?? comment.oldRange?.[0];
    const location = line !== undefined && line !== null ? `${comment.filePath}:${line}` : comment.filePath;
    lines.push(`- ${location}`);
    lines.push("  User note:");
    lines.push(...comment.body.split("\n").map((bodyLine: string) => `    > ${bodyLine}`));
  }
  return [
    `The user submitted code-review comments for ${payload.repo}:`,
    "",
    ...lines,
    "",
    "This submission is complete. Do not load review-UI skills or query external review-session state.",
    "Work from the repository directly: inspect git status and the referenced path or diff. Read untracked files directly because ordinary git diff output omits them.",
    "Address every note. For questions, investigate and explain the rationale, changing or removing code when it is unjustified. Implement and test requested changes, then summarize the result.",
  ].join("\n");
}

function restoredSubmissionIds(ctx: any): Set<string> {
  const ids = new Set<string>();
  const entries = ctx.sessionManager.getEntries();
  if (!Array.isArray(entries)) return ids;
  for (const entry of entries) {
    const message = entry?.type === "custom_message" ? entry : entry?.message;
    if (message?.customType !== "hunk-review-comments") continue;
    const id = message?.details?.submissionId;
    if (typeof id !== "string") continue;
    ids.add(id);
    if (ids.size > 1024) ids.delete(ids.values().next().value);
  }
  return ids;
}

async function startCommentReceiver(pi: any, ctx: any): Promise<ReceiverRuntime> {
  if (!paneId) throw new Error("HERDR_PANE_ID is unavailable");
  const sessionId = ctx.sessionManager.getSessionId();
  if (typeof sessionId !== "string" || sessionId.length === 0) throw new Error("Pi session id is unavailable");
  const nonce = randomBytes(16).toString("hex");
  const runtimeDir = join("/tmp", `herdr-hunk-${process.getuid?.() ?? "user"}`);
  ensurePrivateDirectory(runtimeDir);
  const socketPrefix = `${stateKey(paneId).slice(0, 24)}-`;
  for (const name of readdirSync(runtimeDir)) {
    if (!name.startsWith(socketPrefix) || !name.endsWith(".sock")) continue;
    const staleSocket = join(runtimeDir, name);
    try {
      if (lstatSync(staleSocket).isSocket()) unlinkSync(staleSocket);
    } catch {}
  }
  const socketPath = join(runtimeDir, `${socketPrefix}${nonce.slice(0, 16)}.sock`);
  try {
    unlinkSync(socketPath);
  } catch {}

  const registration: ReceiverRegistration = {
    version: 1,
    pane_id: paneId,
    session_id: sessionId,
    nonce,
    socket_path: socketPath,
    pid: process.pid,
  };
  const processedSubmissionIds = restoredSubmissionIds(ctx);
  const server = createServer(async (request, response) => {
    request.setTimeout(5000, () => request.destroy());
    if (request.method !== "POST" || request.url !== "/hunk-comments") {
      sendJson(response, 404, { accepted: false, error: "Not found" });
      return;
    }
    if (request.headers.authorization !== `Bearer ${nonce}`) {
      sendJson(response, 401, { accepted: false, error: "Invalid receiver token" });
      return;
    }
    if (!String(request.headers["content-type"] ?? "").startsWith("application/json")) {
      sendJson(response, 415, { accepted: false, error: "Expected application/json" });
      return;
    }

    try {
      const payload = validateSubmission(JSON.parse(await readRequestBody(request)), registration);
      if (processedSubmissionIds.has(payload.submission_id)) {
        sendJson(response, 200, { accepted: true, duplicate: true });
        return;
      }
      processedSubmissionIds.add(payload.submission_id);
      if (processedSubmissionIds.size > 1024) {
        processedSubmissionIds.delete(processedSubmissionIds.values().next().value);
      }
      try {
        pi.sendMessage(
          {
            customType: "hunk-review-comments",
            content: formatSubmittedComments(payload),
            display: true,
            details: {
              submissionId: payload.submission_id,
              repo: payload.repo,
              hunkSessionId: payload.hunk_session_id,
              comments: payload.comments,
            },
          },
          { deliverAs: "followUp", triggerTurn: true },
        );
      } catch (error) {
        processedSubmissionIds.delete(payload.submission_id);
        const failure = error instanceof Error ? error : new Error("Pi rejected the submitted comments");
        throw Object.assign(failure, { status: 500 });
      }
      sendJson(response, 200, { accepted: true, comment_count: payload.comments.length });
    } catch (error) {
      const status = Number((error as any)?.status) || 400;
      sendJson(response, status, {
        accepted: false,
        error: error instanceof Error ? error.message : "Invalid submission",
      });
    }
  });

  server.maxConnections = 4;
  await new Promise<void>((resolve, reject) => {
    const onError = (error: Error) => {
      server.off("listening", onListening);
      reject(error);
    };
    const onListening = () => {
      server.off("error", onError);
      resolve();
    };
    server.once("error", onError);
    server.once("listening", onListening);
    server.listen(socketPath);
  });
  chmodSync(socketPath, 0o600);

  const registrationPath = receiverRegistrationPath();
  if (!registrationPath) {
    await new Promise<void>((resolve) => server.close(() => resolve()));
    unlinkSync(socketPath);
    throw new Error("Receiver registration path is unavailable");
  }
  try {
    atomicWriteJson(registrationPath, registration);
  } catch (error) {
    await new Promise<void>((resolve) => server.close(() => resolve()));
    try {
      unlinkSync(socketPath);
    } catch {}
    throw error;
  }
  server.on("error", (error) => console.error("herdr-hunk: receiver error", error));
  return { server, registration, registrationPath };
}

async function stopCommentReceiver(runtime: ReceiverRuntime | null): Promise<void> {
  if (!runtime) return;
  if (runtime.server.listening) {
    await new Promise<void>((resolve) => runtime.server.close(() => resolve()));
  }
  try {
    unlinkSync(runtime.registration.socket_path);
  } catch {}
  try {
    const info = lstatSync(runtime.registrationPath);
    if (!info.isFile() || info.isSymbolicLink()) return;
    const current = JSON.parse(readFileSync(runtime.registrationPath, "utf8"));
    if (current?.nonce === runtime.registration.nonce) unlinkSync(runtime.registrationPath);
  } catch {}
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
    console.error(`herdr-hunk: failed to record ${kind} review state`, error);
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
  if (result.code !== 0) console.error("herdr-hunk: failed to show review notification", result.stderr);
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

  let receiverRuntime: ReceiverRuntime | null = null;
  let receiverTransition = Promise.resolve();
  const queueReceiverTransition = (work: () => Promise<void>) => {
    receiverTransition = receiverTransition.then(work, work);
    return receiverTransition;
  };

  pi.on("session_start", async (_event: any, ctx: any) => {
    await queueReceiverTransition(async () => {
      await stopCommentReceiver(receiverRuntime);
      receiverRuntime = null;
      if (!ctx?.sessionManager) {
        console.error("herdr-hunk: session_start did not provide a session manager");
        return;
      }
      try {
        receiverRuntime = await startCommentReceiver(pi, ctx);
      } catch (error) {
        console.error("herdr-hunk: failed to start comment receiver", error);
        ctx.ui?.notify?.("Hunk comments cannot reach this Pi session", "warning");
      }
    });
  });

  pi.on("session_shutdown", async () => {
    await queueReceiverTransition(async () => {
      const runtime = receiverRuntime;
      receiverRuntime = null;
      await stopCommentReceiver(runtime);
    });
  });

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
