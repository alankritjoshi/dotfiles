---
name: extension-developer
description: >
  Create, update, and maintain pi extensions — TypeScript modules that add tools, intercept events,
  gate commands, and customize UI. Covers directory structure, common patterns (tool-wrapping, guardians,
  state persistence, custom TUI), plan-mode integration (blocklist, tool classification, plan-researcher
  agent), testing with bun:test, and the quality checklist. Use when creating a new extension, adding
  tools to an existing one, updating plan-mode blocklist, or wiring up event handlers.
---

# Extension Developer

Guide for creating and maintaining pi extensions in `~/.pi/agent/extensions/`.

## Directory Structure

```
~/.pi/agent/extensions/
├── my-extension/
│   ├── index.ts          # Entry point (required)
│   ├── helpers.ts         # Pure functions (testable)
│   ├── helpers.test.ts    # Tests
│   └── config.json        # Optional config
├── lib/                   # Shared code across extensions
│   └── guardian/
│       ├── types.ts
│       └── register.ts
```

Multi-file extensions: `index.ts` is the entry point, import siblings with `.js` suffix (`from "./helpers.js"`).

Shared code: put in `lib/` — any extension can import from `../lib/`.

## Minimal Extension

```typescript
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // Register tools, commands, events, shortcuts here
}
```

## Common Patterns

### Pattern 1: CLI Tool Wrapper

Wrap a CLI tool (gh, gt, dev) into pi tools. See `github/index.ts`, `graphite/index.ts`.

```typescript
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { Text } from "@mariozechner/pi-tui";

export default function (pi: ExtensionAPI) {
  // Shared exec helper
  async function cli(args: string[], signal?: AbortSignal): Promise<string> {
    const result = await pi.exec("mycli", args, { signal, timeout: 30000 });
    if (result.code !== 0) {
      throw new Error(result.stderr.trim() || `mycli exited with code ${result.code}`);
    }
    return result.stdout;
  }

  // Shared result helpers
  function ok(text: string, details?: Record<string, any>) {
    return { content: [{ type: "text" as const, text }], details: details ?? {} };
  }
  function errorResult(err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    return { content: [{ type: "text" as const, text: `Error: ${msg}` }], details: { error: true } };
  }

  pi.registerTool({
    name: "my_tool",
    label: "My Tool",
    description: "Does something useful",
    promptSnippet: "One-line for system prompt Available Tools section",
    parameters: Type.Object({
      query: Type.String({ description: "Search query" }),
      limit: Type.Optional(Type.Number({ description: "Max results" })),
    }),
    async execute(_id, params, signal) {
      try {
        const out = await cli(["search", params.query, "--limit", String(params.limit ?? 10)], signal);
        return ok(out, { query: params.query });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      const a = args as { query?: string };
      return new Text(
        theme.fg("toolTitle", theme.bold("my_tool ")) +
        theme.fg("muted", a.query ?? ""),
        0, 0,
      );
    },
    renderResult(result, _opts, theme) {
      if (result.details?.error) {
        const t = result.content?.[0];
        return new Text(theme.fg("error", t && "text" in t ? t.text : "Error"), 0, 0);
      }
      const t = result.content?.[0];
      return new Text(t && "text" in t ? t.text : "", 0, 0);
    },
  });
}
```

### Pattern 2: Command Guardian

Intercept and gate dangerous bash commands. Uses the shared `lib/guardian/` framework.

```typescript
// my-guardian/index.ts
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { registerGuardian } from "../lib/guardian/register.js";
import type { CommandGuardian } from "../lib/guardian/types.js";

interface ParsedDeploy { target: string; force: boolean }

const deployGuardian: CommandGuardian<ParsedDeploy> = {
  detect(cmd) { return /\bdeploy\b/.test(cmd); },
  parse(cmd) {
    const match = cmd.match(/deploy\s+(\S+)/);
    if (!match) return null;
    return { target: match[1], force: cmd.includes("--force") };
  },
  async review(parsed, _event, ctx) {
    if (!parsed.force) return undefined; // allow non-force deploys
    const ok = await ctx.ui.confirm(
      "Force Deploy",
      `Force deploy to ${parsed.target}?`,
    );
    if (!ok) return { block: true, reason: "User cancelled force deploy" };
    return undefined;
  },
};

export default function (pi: ExtensionAPI) {
  registerGuardian(pi, deployGuardian);
}
```

Guardian types (`lib/guardian/types.ts`):
- `detect(command)` → boolean: should this guardian handle it?
- `parse(command)` → T | null: structured parse, null to skip
- `review(parsed, event, ctx)` → `undefined` (allow), `{ block, reason }`, or `{ rewrite }` (mutate command)

### Pattern 3: State Persistence

For extensions that maintain state across sessions.

```typescript
// Persist state
pi.appendEntry("my-extension", { counter: 42, items: ["a", "b"] });

// Restore in session_start
pi.on("session_start", async (_event, ctx) => {
  const entries = ctx.sessionManager.getEntries();
  const last = entries
    .filter((e) => e.type === "custom" && e.customType === "my-extension")
    .pop();
  if (last?.data) {
    // restore from last.data
  }
});

// Also handle session_switch, session_fork, session_tree
pi.on("session_switch", async (_event, ctx) => restoreState(ctx));
pi.on("session_fork", async (_event, ctx) => restoreState(ctx));
pi.on("session_tree", async (_event, ctx) => restoreState(ctx));
```

### Pattern 4: System Prompt Injection

Inject context before the agent starts.

```typescript
pi.on("before_agent_start", async () => {
  return {
    message: {
      customType: "my-context",
      content: "You have access to ...",
      display: false, // don't show in chat
    },
  };
});

// Clean up old injections in context handler
pi.on("context", async (event) => {
  let lastIdx = -1;
  for (let i = event.messages.length - 1; i >= 0; i--) {
    if ((event.messages[i] as any).customType === "my-context") {
      lastIdx = i;
      break;
    }
  }
  return {
    messages: event.messages.filter((m, i) => {
      if ((m as any).customType === "my-context" && i !== lastIdx) return false;
      return true;
    }),
  };
});
```

### Pattern 5: Custom TUI Component

For complex interactive UI (see `plan-mode/interview.ts`).

```typescript
const result = await ctx.ui.custom<MyResult | null>((tui, theme, _kb, done) => {
  let state = { /* ... */ };

  function handleInput(data: string) {
    if (matchesKey(data, Key.escape)) { done(null); return; }
    if (matchesKey(data, Key.enter)) { done(state); return; }
    // handle other keys, update state
  }

  function render(width: number): string[] {
    // return array of lines to display
    return [theme.fg("accent", "My UI"), `Width: ${width}`];
  }

  return { render, invalidate: () => {}, handleInput };
});
```

### Pattern 6: Config File

Load config from the extension directory.

```typescript
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

const CONFIG_PATH = path.join(os.homedir(), ".pi", "agent", "extensions", "my-ext", "config.json");

interface MyConfig { maxItems?: number; enabled?: boolean }

function loadConfig(): MyConfig {
  try {
    return JSON.parse(fs.readFileSync(CONFIG_PATH, "utf-8"));
  } catch {
    return {};
  }
}
```

## Plan Mode Integration

When creating or updating extensions that register tools, you MUST update the plan-mode blocklist.

### Classifying Tools

After adding new tools, run `/plan-classify-tools`. This:
1. Discovers all unclassified tools
2. Heuristically classifies them as blocked or allowed
3. Saves to `~/.pi/agent/extensions/plan-mode/blocklist.json`
4. Updates the `plan-researcher` agent's tools list

### Manual Classification

Edit `~/.pi/agent/extensions/plan-mode/blocklist.json` directly:

```json
{
  "blocked": ["my_dangerous_tool"],
  "allowed": ["my_read_tool", "my_query_tool"],
  "lastClassified": "2026-03-16"
}
```

**Block** tools that: write files, start processes, deploy, delete, modify state, or have uncontrollable side effects.

**Allow** tools that: read, search, query, list, fetch, analyze, inspect, or are purely informational.

Core blocked (`edit`, `write`) are always blocked regardless of this file.

### Plan-Researcher Agent

The file `~/.pi/agent/agents/plan-researcher.md` defines the subagent used for parallel research in plan mode. Its `tools:` field is auto-updated by `/plan-classify-tools`.

If you add a read-only tool that should be available to the plan-researcher, either:
- Run `/plan-classify-tools` (auto-updates the agent)
- Or manually add it to the `tools:` field in `plan-researcher.md`

Tools excluded from the researcher (parent-only): `plan_interview`, `ask`, `bg_list`, `bg_log`, `bg_wait`, `read_output_chunk`, `search_output`, `subagent`, `bash`.

### Subagent Restriction

In plan mode, `subagent` calls are intercepted. Only the `plan-researcher` agent is allowed. This is enforced in `plan-mode/index.ts` via a `tool_call` handler that checks single, parallel, and chain modes.

## Testing

Extract pure functions into separate files and test with `bun:test`.

```typescript
// helpers.test.ts
import { describe, expect, test } from "bun:test";
import { myFunction } from "./helpers.js";

describe("myFunction", () => {
  test("handles basic input", () => {
    expect(myFunction("hello")).toBe("HELLO");
  });
});
```

Run: `cd ~/.pi/agent/extensions/my-ext && npx bun test`

Keep tool `execute` functions thin — delegate logic to testable helpers.

## Quality Checklist

Before finishing an extension:

- [ ] Default export function receiving `ExtensionAPI`
- [ ] Imports: `@mariozechner/pi-coding-agent` for types, `@sinclair/typebox` for schemas, `@mariozechner/pi-tui` for UI
- [ ] `StringEnum` from `@mariozechner/pi-ai` for string enum params (NOT `Type.Union`/`Type.Literal` — breaks Google)
- [ ] Tool execute signature: `(toolCallId, params, signal, onUpdate, ctx)`
- [ ] `signal?.aborted` checks in async tools
- [ ] `ctx.hasUI` check before UI dialogs (`select`, `confirm`, `input`)
- [ ] Output truncation for large results (50KB / 2000 lines)
- [ ] `renderCall` and `renderResult` for tools (use `Text` with `0, 0` padding)
- [ ] Theme colors via `theme.fg("accent"|"error"|"muted"|"dim"|"success", ...)` — never hardcoded ANSI
- [ ] `try/catch` around external calls (`pi.exec`, file I/O, network)
- [ ] Session lifecycle: `session_start`, `session_switch`, `session_fork`, `session_tree` if stateful
- [ ] `promptSnippet` for concise system prompt entry, `promptGuidelines` for usage rules
- [ ] Plan mode: run `/plan-classify-tools` after adding new tools
- [ ] Tests for pure logic in separate `.test.ts` files

## Reference

- Pi extension docs: read `/nix/store/hzcf5vfkr9cln378lzy5dfy39jin26p6-pi-coding-agent-0.58.1/lib/node_modules/pi-monorepo/docs/extensions.md`
- Extension examples: `/nix/store/hzcf5vfkr9cln378lzy5dfy39jin26p6-pi-coding-agent-0.58.1/lib/node_modules/pi-monorepo/examples/extensions/`
- Extension analyzer skill: use `/skill:extension-analyzer` to review an extension after writing it
- Existing extensions: `~/.pi/agent/extensions/` — `plan-mode/`, `github/`, `graphite/`, `git-guardian/`, `memory/`, `background-jobs/`
- Guardian framework: `~/.pi/agent/extensions/lib/guardian/`
- Plan-mode blocklist: `~/.pi/agent/extensions/plan-mode/blocklist.json`
- Plan-researcher agent: `~/.pi/agent/agents/plan-researcher.md`
