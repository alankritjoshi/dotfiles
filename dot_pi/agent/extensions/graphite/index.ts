import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { Text } from "@mariozechner/pi-tui";

export default function (pi: ExtensionAPI) {
  async function gt(
    args: string[],
    signal?: AbortSignal,
    cwd?: string,
  ): Promise<string> {
    const result = await pi.exec("gt", args, { signal, timeout: 30000, cwd });
    if (result.code !== 0) {
      const msg = result.stderr.trim() || result.stdout.trim() || `gt exited with code ${result.code}`;
      throw new Error(msg);
    }
    return result.stdout;
  }

  function ok(text: string, details?: Record<string, any>) {
    return {
      content: [{ type: "text" as const, text }],
      details: details ?? {},
    };
  }

  function errorResult(err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    return {
      content: [{ type: "text" as const, text: `Error: ${msg}` }],
      details: { error: true },
    };
  }

  // ─── gt_stack ─────────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gt_stack",
    label: "Graphite — Stack",
    description:
      "Show the current stack structure. Equivalent to `gt log short`. " +
      "Shows all branches in the stack with their relationships.",
    parameters: Type.Object({}),
    async execute(_id, _params, signal) {
      try {
        const output = await gt(["log", "short"], signal);
        return ok(output.trim() || "(empty stack — on trunk)");
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(_args, theme) {
      return new Text(theme.fg("toolTitle", theme.bold("Graphite — Stack")), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ stack"), 0, 0);
    },
  });

  // ─── gt_ls ────────────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gt_ls",
    label: "Graphite — List Branches",
    description:
      "Show branch tree visualization. Equivalent to `gt ls`. " +
      "Shows branches as a visual tree with current branch marked.",
    parameters: Type.Object({}),
    async execute(_id, _params, signal) {
      try {
        const output = await gt(["ls"], signal);
        return ok(output.trim() || "(no tracked branches)");
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(_args, theme) {
      return new Text(theme.fg("toolTitle", theme.bold("Graphite — List")), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ branches"), 0, 0);
    },
  });

  // ─── gt_create ────────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gt_create",
    label: "Graphite — Create Branch",
    description:
      "Create a new stacked branch on top of the current branch. " +
      "Stages and commits all changes with the given message. " +
      "Equivalent to `gt create <name> -a -m <message>`.",
    parameters: Type.Object({
      name: Type.String({ description: "Branch name (e.g. 'add-feature-x')" }),
      message: Type.Optional(Type.String({ description: "Commit message. If omitted, opens editor." })),
      all: Type.Optional(Type.Boolean({ description: "Stage all changes before committing (default: true)" })),
    }),
    async execute(_id, params, signal) {
      try {
        const args = ["create", params.name];
        if (params.all !== false) args.push("-a");
        if (params.message) args.push("-m", params.message);
        const output = await gt(args, signal);
        return ok(output.trim() || `Created branch: ${params.name}`, { branch: params.name });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      return new Text(theme.fg("toolTitle", theme.bold("Graphite — Create ")) + theme.fg("muted", args.name), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ ") + `created ${d.branch}`, 0, 0);
    },
  });

  // ─── gt_modify ────────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gt_modify",
    label: "Graphite — Modify",
    description:
      "Amend the current branch's commit. Stages all changes and amends. " +
      "Use --into to amend into a specific downstack branch. " +
      "Auto-restacks descendants after amending.",
    parameters: Type.Object({
      message: Type.Optional(Type.String({ description: "New commit message (omit to keep existing)" })),
      commit: Type.Optional(Type.Boolean({ description: "Create a new commit instead of amending" })),
      all: Type.Optional(Type.Boolean({ description: "Stage all changes first (default: true)" })),
      into: Type.Optional(Type.String({ description: "Amend into a specific downstack branch instead of current" })),
    }),
    async execute(_id, params, signal) {
      try {
        const args = ["modify"];
        if (params.all !== false) args.push("-a");
        if (params.commit) args.push("--commit");
        if (params.message) args.push("-m", params.message);
        if (params.into) args.push("--into", params.into);
        const output = await gt(args, signal);
        return ok(output.trim() || "Modified current branch.", { into: params.into });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      const target = args.into ? `--into ${args.into}` : "current";
      return new Text(theme.fg("toolTitle", theme.bold("Graphite — Modify ")) + theme.fg("muted", target), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ modified"), 0, 0);
    },
  });

  // ─── gt_checkout ──────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gt_checkout",
    label: "Graphite — Checkout",
    description:
      "Switch to a branch in the stack. Also supports: top (tip), bottom (base), " +
      "up/down (relative navigation).",
    parameters: Type.Object({
      target: Type.String({
        description: "Branch name, or: 'top', 'bottom', 'up', 'down', 'up 2', 'down 3', 'trunk'",
      }),
    }),
    async execute(_id, params, signal) {
      try {
        const t = params.target.trim();
        let output: string;

        if (t === "top") {
          output = await gt(["top"], signal);
        } else if (t === "bottom") {
          output = await gt(["bottom"], signal);
        } else if (t === "trunk") {
          output = await gt(["trunk"], signal);
        } else if (t.startsWith("up")) {
          const n = t.replace("up", "").trim();
          output = await gt(n ? ["up", n] : ["up"], signal);
        } else if (t.startsWith("down")) {
          const n = t.replace("down", "").trim();
          output = await gt(n ? ["down", n] : ["down"], signal);
        } else {
          output = await gt(["checkout", t], signal);
        }

        return ok(output.trim() || `Switched to ${t}`, { target: t });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      return new Text(theme.fg("toolTitle", theme.bold("Graphite — Checkout ")) + theme.fg("muted", args.target), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ ") + d.target, 0, 0);
    },
  });

  // ─── gt_submit ────────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gt_submit",
    label: "Graphite — Submit",
    description:
      "Push branches and create/update PRs on GitHub. " +
      "Equivalent to `gt submit`. Use --stack to submit the entire stack.",
    parameters: Type.Object({
      stack: Type.Optional(Type.Boolean({ description: "Submit entire stack (default: false, submits current branch only)" })),
      draft: Type.Optional(Type.Boolean({ description: "Create PRs as drafts" })),
      noEdit: Type.Optional(Type.Boolean({ description: "Skip PR description editor (default: true)" })),
    }),
    async execute(_id, params, signal) {
      try {
        const args = ["submit"];
        if (params.stack) args.push("--stack");
        if (params.draft) args.push("--draft");
        if (params.noEdit !== false) args.push("--no-edit");
        const output = await gt(args, signal);
        return ok(output.trim() || "Submitted.", { stack: !!params.stack });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      const scope = args.stack ? "stack" : "current";
      return new Text(theme.fg("toolTitle", theme.bold("Graphite — Submit ")) + theme.fg("muted", scope), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ submitted") + (d.stack ? " (stack)" : ""), 0, 0);
    },
  });

  // ─── gt_restack ───────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gt_restack",
    label: "Graphite — Restack",
    description:
      "Rebase all branches to ensure proper parent relationships. " +
      "Run after manual git operations or when branches need restacking.",
    parameters: Type.Object({
      scope: Type.Optional(Type.String({
        description: "Scope: 'all' (default), 'upstack', 'downstack', or 'only' (current branch)",
      })),
    }),
    async execute(_id, params, signal) {
      try {
        const args = ["restack"];
        const scope = params.scope ?? "all";
        if (scope === "upstack") args.push("--upstack");
        else if (scope === "downstack") args.push("--downstack");
        else if (scope === "only") args.push("--only");
        const output = await gt(args, signal);
        return ok(output.trim() || "Restacked.", { scope });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      return new Text(theme.fg("toolTitle", theme.bold("Graphite — Restack ")) + theme.fg("muted", args.scope ?? "all"), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ restacked") + ` (${d.scope})`, 0, 0);
    },
  });

  // ─── gt_sync ──────────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gt_sync",
    label: "Graphite — Sync",
    description:
      "Sync all branches from remote. Prompts to delete merged branches. " +
      "Equivalent to `gt sync`.",
    parameters: Type.Object({}),
    async execute(_id, _params, signal) {
      try {
        const output = await gt(["sync"], signal);
        return ok(output.trim() || "Synced.");
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(_args, theme) {
      return new Text(theme.fg("toolTitle", theme.bold("Graphite — Sync")), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ synced"), 0, 0);
    },
  });

  // ─── gt_branch_info ───────────────────────────────────────────────────────

  pi.registerTool({
    name: "gt_branch_info",
    label: "Graphite — Branch Info",
    description:
      "Show detailed info about the current branch or a specific branch. " +
      "Shows parent, children, PR status, and commit details.",
    parameters: Type.Object({
      branch: Type.Optional(Type.String({ description: "Branch name (default: current)" })),
    }),
    async execute(_id, params, signal) {
      try {
        const logOutput = await gt(["log", "long"], signal);

        const lines = [`Stack:\n${logOutput.trim()}`];

        if (params.branch) {
          lines.unshift(`Branch: ${params.branch}`);
        }

        return ok(lines.join("\n\n"), { branch: params.branch ?? "current" });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      return new Text(
        theme.fg("toolTitle", theme.bold("Graphite — Branch Info ")) +
        theme.fg("muted", args.branch ?? "current"),
        0, 0,
      );
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ ") + d.branch, 0, 0);
    },
  });
}
