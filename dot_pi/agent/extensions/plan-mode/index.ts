/**
 * Plan Mode Extension
 *
 * Read-only exploration mode with enforced tool restrictions.
 *
 * Uses a blocklist approach: all tools available except explicitly blocked ones.
 * Blocked tools persisted in blocklist.json, classifiable via /plan-classify.
 * Core blocked (edit, write) are always blocked regardless of blocklist.
 *
 * State machine: Normal ↔ Plan ↔ Execution (todos preserved across toggles)
 * Todos only clear on: all steps done, /plan clear, or /plan [new-topic].
 *
 * Features:
 * - Shift+Tab to toggle plan mode (no topic required)
 * - /plan [topic] to toggle; optional topic sets plan file name
 * - /plan clear to explicitly wipe todos and topic
 * - /plan-classify to heuristically classify tools and agents for plan mode
 * - --plan flag to start in plan mode
 * - Bash restricted to allowlisted read-only commands
 * - save_plan tool writes plan to .pi/plans/<topic>.md and opens md preview
 * - save_plan allowed in plan mode (bypasses write restriction)
 * - [DONE:n] progress tracking
 * - Todo widget above editor for plan step tracking
 * - Custom header banner when plan mode is active
 */

import type { AgentMessage } from "@mariozechner/pi-agent-core";
import type { AssistantMessage, TextContent } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Key, Text } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";
import * as fs from "node:fs";
import * as path from "node:path";
import { spawn } from "node:child_process";
import { isSafeCommand, markCompletedSteps, type TodoItem } from "./utils.js";
import { classifyAllTools, classifyAllAgents, getBlockedTools, getAllowedAgents, getUnclassifiedTools, saveBlocklist, CORE_BLOCKED } from "./classify.js";

function isAssistantMessage(m: AgentMessage): m is AssistantMessage {
	return m.role === "assistant" && Array.isArray(m.content);
}

function getTextContent(message: AssistantMessage): string {
	return message.content
		.filter((block): block is TextContent => block.type === "text")
		.map((block) => block.text)
		.join("\n");
}

function slugify(text: string): string {
	return text
		.toLowerCase()
		.replace(/[^a-z0-9]+/g, "-")
		.replace(/^-|-$/g, "")
		.slice(0, 60);
}

function ensurePlansDir(cwd: string): string {
	const plansDir = path.join(cwd, ".pi", "plans");
	fs.mkdirSync(plansDir, { recursive: true });
	return plansDir;
}

function writePlanFile(cwd: string, topic: string, content: string): string {
	const plansDir = ensurePlansDir(cwd);
	const filename = `${slugify(topic)}.md`;
	const filePath = path.join(plansDir, filename);
	fs.writeFileSync(filePath, content, "utf-8");
	return filePath;
}

export default function planModeExtension(pi: ExtensionAPI): void {
	let planModeEnabled = false;
	let executionMode = false;
	let todoItems: TodoItem[] = [];
	let planTopic: string | null = null;
	let allToolNames: string[] = [];
	let planSavedThisTurn = false;

	function captureAllTools(): void {
		allToolNames = pi.getAllTools().map((t) => t.name);
	}

	function restoreAllTools(): void {
		if (allToolNames.length > 0) {
			pi.setActiveTools(allToolNames);
		} else {
			captureAllTools();
			if (allToolNames.length > 0) {
				pi.setActiveTools(allToolNames);
			}
		}
	}

	function getPlanModeTools(): string[] {
		const blocked = getBlockedTools();
		return pi.getAllTools().map((t) => t.name).filter((name) => !blocked.has(name));
	}

	pi.registerFlag("plan", {
		description: "Start in plan mode (read-only exploration)",
		type: "boolean",
		default: false,
	});

	// --- Register plan steps tool ---

	pi.registerTool({
		name: "register_plan_steps",
		label: "Register Plan Steps",
		description: "Register plan steps as trackable todos. Call this after producing a plan to make steps trackable in the todo widget.",
		promptSnippet: "Register plan steps as trackable todos after producing a plan.",
		promptGuidelines: [
			"After producing a plan with numbered steps, call register_plan_steps with the step descriptions.",
			"Each step should be a concise action item (not a section header or question).",
			"Only include actionable implementation steps — not context, approach, or open questions.",
		],
		parameters: Type.Object({
			steps: Type.Array(Type.String({ description: "Step description" }), {
				description: "Array of plan step descriptions in execution order.",
			}),
		}),
		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			if (!params.steps || params.steps.length === 0) {
				return { content: [{ type: "text", text: "No steps provided." }], isError: true };
			}
			todoItems = params.steps.map((text, i) => ({
				step: i + 1,
				text: text.length > 70 ? `${text.slice(0, 67)}...` : text,
				completed: false,
			}));
			updateTodoDisplay(ctx);
			updateStatus(ctx);
			persistState();

			return {
				content: [{ type: "text", text: `${todoItems.length} plan steps registered.` }],
				details: { steps: todoItems.map((t) => t.text) },
			};
		},
		renderCall(args, theme) {
			const a = args as { steps?: string[] };
			const count = a.steps?.length ?? 0;
			return new Text(
				theme.fg("toolTitle", theme.bold("register_plan_steps ")) +
				theme.fg("muted", `${count} step${count !== 1 ? "s" : ""}`),
				0, 0,
			);
		},
		renderResult(result, _options, theme) {
			const d = result.details as { steps?: string[] } | undefined;
			if (!d?.steps?.length) {
				const t = result.content?.[0];
				return new Text(t && "text" in t ? t.text : "", 0, 0);
			}
			const lines = d.steps.map((s, i) =>
				`${theme.fg("dim", `${i + 1}.`)} ${s}`,
			);
			return new Text(
				theme.fg("success", `✓ ${d.steps.length} steps registered\n`) + lines.join("\n"),
				0, 0,
			);
		},
	});

	// --- Complete plan step tool ---

	pi.registerTool({
		name: "complete_plan_step",
		label: "Complete Plan Step",
		description: "Mark one or more plan steps as completed.",
		promptSnippet: "Mark plan steps as completed by step number.",
		promptGuidelines: [
			"After completing a plan step, call complete_plan_step with the step number(s).",
			"Call this instead of using [DONE:n] text tags.",
		],
		parameters: Type.Object({
			steps: Type.Array(Type.Number({ description: "Step number (1-indexed)" }), {
				description: "Step numbers to mark as completed.",
			}),
		}),
		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			if (!params.steps || params.steps.length === 0) {
				return { content: [{ type: "text", text: "No step numbers provided." }], isError: true };
			}
			const marked: number[] = [];
			for (const step of params.steps) {
				const item = todoItems.find((t) => t.step === step);
				if (item && !item.completed) {
					item.completed = true;
					marked.push(step);
				}
			}
			updateTodoDisplay(ctx);
			updateStatus(ctx);
			persistState();

			if (todoItems.length > 0 && todoItems.every((t) => t.completed)) {
				todoItems = [];
				if (executionMode) {
					executionMode = false;
					restoreAllTools();
					clearHeader(ctx);
				}
				updateStatus(ctx);
				ctx.ui.setWidget("plan-todos", undefined);
				persistState();
				return {
					content: [{ type: "text", text: `Completed step(s) ${marked.join(", ")}. All steps done!` }],
					details: { completed: marked, allDone: true },
				};
			}

			const remaining = todoItems.filter((t) => !t.completed).length;
			return {
				content: [{ type: "text", text: `Completed step(s) ${marked.join(", ")}. ${remaining} remaining.` }],
				details: { completed: marked, remaining },
			};
		},
		renderCall(args, theme) {
			const a = args as { steps?: number[] };
			const nums = a.steps?.join(", ") ?? "";
			return new Text(
				theme.fg("toolTitle", theme.bold("complete_plan_step ")) +
				theme.fg("muted", `#${nums}`),
				0, 0,
			);
		},
		renderResult(result, _options, theme) {
			const d = result.details as { completed?: number[]; remaining?: number; allDone?: boolean } | undefined;
			if (d?.allDone) {
				return new Text(theme.fg("success", "✓ All steps complete"), 0, 0);
			}
			const t = result.content?.[0];
			return new Text(t && "text" in t ? t.text : "", 0, 0);
		},
	});

	// --- Save plan tool ---

	pi.registerTool({
		name: "save_plan",
		label: "Save Plan",
		description: "Save the plan to .pi/plans/<topic>.md and open a markdown preview. Only works when a plan topic is set via /plan <topic>.",
		promptSnippet: "Save plan to file and open markdown preview.",
		promptGuidelines: [
			"After register_plan_steps, call save_plan with the full plan markdown content.",
			"Only call this when a plan topic is set (via /plan <topic>).",
		],
		parameters: Type.Object({
			content: Type.String({ description: "Full plan content in markdown format." }),
		}),
		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			if (!planTopic) {
				return { content: [{ type: "text", text: "No plan topic set. Use /plan <topic> first." }], isError: true };
			}
			if (!params.content?.trim()) {
				return { content: [{ type: "text", text: "Empty plan content." }], isError: true };
			}

			try {
				const filePath = writePlanFile(ctx.cwd, planTopic, `# Plan: ${planTopic}\n\n${params.content}`);
				planSavedThisTurn = true;

				spawn("md", [filePath], {
					detached: true,
					stdio: "ignore",
				}).unref();

				return {
					content: [{ type: "text", text: `Plan saved to ${filePath}` }],
					details: { path: filePath, topic: planTopic },
				};
			} catch (err) {
				return { content: [{ type: "text", text: `Failed to save plan: ${err}` }], isError: true };
			}
		},
		renderCall(args, theme) {
			const a = args as { content?: string };
			const preview = a.content?.slice(0, 60) ?? "";
			return new Text(
				theme.fg("toolTitle", theme.bold("save_plan ")) +
				theme.fg("muted", preview.length === 60 ? `${preview}…` : preview),
				0, 0,
			);
		},
		renderResult(result, _options, theme) {
			if (result.isError) {
				const t = result.content?.[0];
				return new Text(theme.fg("error", t && "text" in t ? t.text : "Error"), 0, 0);
			}
			const d = result.details as { path?: string } | undefined;
			return new Text(theme.fg("success", `✓ Saved to ${d?.path ?? "plan file"}`), 0, 0);
		},
	});

	// --- Todo widget ---

	function updateTodoDisplay(ctx: ExtensionContext): void {
		if (todoItems.length === 0) {
			ctx.ui.setWidget("plan-todos", undefined);
			return;
		}

		const completed = todoItems.filter((t) => t.completed).length;
		const title = executionMode ? `▶ Executing ${completed}/${todoItems.length}` : `📋 Plan ${completed}/${todoItems.length}`;

		const lines = [ctx.ui.theme.fg("accent", title)];
		for (const item of todoItems) {
			if (item.completed) {
				lines.push(ctx.ui.theme.fg("success", " ☑ ") + ctx.ui.theme.fg("muted", item.text));
			} else {
				lines.push(ctx.ui.theme.fg("dim", " ☐ ") + item.text);
			}
		}
		ctx.ui.setWidget("plan-todos", lines);
	}

	// --- UI ---

	function setPlanHeader(ctx: ExtensionContext): void {
		ctx.ui.setHeader((_tui, theme) => {
			return {
				render(_width: number): string[] {
					const topicStr = planTopic ? theme.fg("muted", ` "${planTopic}"`) : "";
					const banner = theme.fg("warning", theme.bold("🔒 PLAN MODE")) +
						theme.fg("muted", " — read-only") +
						topicStr +
						theme.fg("dim", "  Shift+Tab to exit");
					return ["", banner, ""];
				},
				invalidate() {},
			};
		});
	}

	function setExecutionHeader(ctx: ExtensionContext): void {
		ctx.ui.setHeader((_tui, theme) => {
			return {
				render(_width: number): string[] {
					const completed = todoItems.filter((t) => t.completed).length;
					const banner = theme.fg("accent", theme.bold("▶ EXECUTING")) +
						theme.fg("muted", ` — ${completed}/${todoItems.length} steps`) +
						theme.fg("dim", "  Shift+Tab for plan mode");
					return ["", banner, ""];
				},
				invalidate() {},
			};
		});
	}

	function clearHeader(ctx: ExtensionContext): void {
		ctx.ui.setHeader(undefined);
	}

	function updateStatus(ctx: ExtensionContext): void {
		if (executionMode && todoItems.length > 0) {
			const completed = todoItems.filter((t) => t.completed).length;
			ctx.ui.setStatus("plan-mode", ctx.ui.theme.fg("accent", `📋 ${completed}/${todoItems.length}`));
		} else if (planModeEnabled) {
			ctx.ui.setStatus("plan-mode", ctx.ui.theme.fg("warning", "⏸ plan"));
		} else {
			ctx.ui.setStatus("plan-mode", undefined);
		}
	}

	// --- Mode toggling ---

	function enablePlanMode(ctx: ExtensionContext, topic?: string): void {
		captureAllTools();
		planModeEnabled = true;
		executionMode = false;
		if (topic) {
			planTopic = topic;
			todoItems = [];
		}

		pi.setActiveTools(getPlanModeTools());
		setPlanHeader(ctx);
		updateStatus(ctx);
		updateTodoDisplay(ctx);
		persistState();

		const topicMsg = planTopic ? ` Topic: "${planTopic}"` : "";
		const unclassified = getUnclassifiedTools(pi.getAllTools());
		const unclassifiedMsg = unclassified.length > 0
			? ` ${unclassified.length} unclassified tool${unclassified.length !== 1 ? "s" : ""} — run /plan-classify`
			: "";
		ctx.ui.notify(`Plan mode enabled.${topicMsg}${unclassifiedMsg}`, "info");
	}

	function togglePlanMode(ctx: ExtensionContext): void {
		if (planModeEnabled) {
			if (todoItems.length > 0 && todoItems.some((t) => !t.completed)) {
				planModeEnabled = false;
				executionMode = true;
				restoreAllTools();
				setExecutionHeader(ctx);
				updateStatus(ctx);
				updateTodoDisplay(ctx);
				persistState();
				ctx.ui.notify("Execution mode — full tool access. Complete the plan steps.", "info");
			} else {
				planModeEnabled = false;
				restoreAllTools();
				clearHeader(ctx);
				updateStatus(ctx);
				persistState();
				ctx.ui.notify("Plan mode disabled. Full access restored.", "info");
			}
		} else if (executionMode) {
			executionMode = false;
			planModeEnabled = true;
			captureAllTools();
			pi.setActiveTools(getPlanModeTools());
			setPlanHeader(ctx);
			updateStatus(ctx);
			updateTodoDisplay(ctx);
			persistState();
			ctx.ui.notify("Back to plan mode. Todos preserved.", "info");
		} else {
			enablePlanMode(ctx);
		}
	}

	// --- State persistence ---

	function persistState(): void {
		pi.appendEntry("plan-mode", {
			enabled: planModeEnabled,
			todos: todoItems,
			executing: executionMode,
			topic: planTopic,
		});
	}

	// --- State restoration (for session lifecycle) ---

	function restoreState(ctx: ExtensionContext): void {
		planModeEnabled = false;
		executionMode = false;
		todoItems = [];
		planTopic = null;

		const entries = ctx.sessionManager.getEntries();

		const planModeEntry = entries
			.filter((e: { type: string; customType?: string }) => e.type === "custom" && e.customType === "plan-mode")
			.pop() as { data?: { enabled: boolean; todos?: TodoItem[]; executing?: boolean; topic?: string } } | undefined;

		if (planModeEntry?.data) {
			planModeEnabled = planModeEntry.data.enabled ?? false;
			todoItems = planModeEntry.data.todos ?? [];
			executionMode = planModeEntry.data.executing ?? false;
			planTopic = planModeEntry.data.topic ?? null;
		}

		if (executionMode && todoItems.length > 0) {
			let executeIndex = -1;
			for (let i = entries.length - 1; i >= 0; i--) {
				const entry = entries[i] as { type: string; customType?: string };
				if (entry.customType === "plan-mode-execute") {
					executeIndex = i;
					break;
				}
			}

			const messages: AssistantMessage[] = [];
			for (let i = executeIndex + 1; i < entries.length; i++) {
				const entry = entries[i];
				if (entry.type === "message" && "message" in entry && isAssistantMessage(entry.message as AgentMessage)) {
					messages.push(entry.message as AssistantMessage);
				}
			}
			const allText = messages.map(getTextContent).join("\n");
			markCompletedSteps(allText, todoItems);
		}

		applyUI(ctx);
	}

	function applyUI(ctx: ExtensionContext): void {
		if (planModeEnabled) {
			pi.setActiveTools(getPlanModeTools());
			setPlanHeader(ctx);
		} else if (executionMode) {
			restoreAllTools();
			setExecutionHeader(ctx);
		} else {
			restoreAllTools();
			clearHeader(ctx);
		}
		updateStatus(ctx);
		updateTodoDisplay(ctx);
	}

	// --- Commands ---

	pi.registerCommand("plan", {
		description: "Toggle plan mode. Usage: /plan [topic] | /plan clear",
		handler: async (args, ctx) => {
			const topic = args?.trim();

			if (topic?.toLowerCase() === "clear") {
				todoItems = [];
				planTopic = null;
				planModeEnabled = false;
				executionMode = false;
				restoreAllTools();
				clearHeader(ctx);
				updateStatus(ctx);
				ctx.ui.setWidget("plan-todos", undefined);
				persistState();
				ctx.ui.notify("Plan cleared. Full access restored.", "info");
				return;
			}

			if (planModeEnabled && topic) {
				planTopic = topic;
				todoItems = [];
				persistState();
				setPlanHeader(ctx);
				updateTodoDisplay(ctx);
				ctx.ui.notify(`New plan topic: "${topic}". Previous todos cleared.`, "info");
				return;
			}

			if (topic && !planModeEnabled) {
				enablePlanMode(ctx, topic);
				return;
			}

			togglePlanMode(ctx);
		},
	});

	pi.registerCommand("todos", {
		description: "Show current plan todo list",
		handler: async (_args, ctx) => {
			if (todoItems.length === 0) {
				ctx.ui.notify("No todos. Create a plan first with /plan", "info");
				return;
			}
			const list = todoItems.map((item, i) => `${i + 1}. ${item.completed ? "✓" : "○"} ${item.text}`).join("\n");
			ctx.ui.notify(`Plan Progress:\n${list}`, "info");
		},
	});

	pi.registerCommand("plan-classify", {
		description: "Classify all tools and agents for plan mode (blocked/allowed)",
		handler: async (_args, ctx) => {
			const allTools = pi.getAllTools();
			const toolResult = classifyAllTools(allTools);
			const blockedTools = new Set([...CORE_BLOCKED, ...toolResult.blocked]);
			const agentResult = classifyAllAgents(blockedTools);
			saveBlocklist(toolResult.blocked, toolResult.allowed, agentResult.blockedAgents, agentResult.allowedAgents);

			const lines: string[] = [];

			if (toolResult.newlyClassified.length > 0) {
				lines.push(`Classified ${toolResult.newlyClassified.length} new tool(s):`);
				for (const { name, classification } of toolResult.newlyClassified) {
					const icon = classification === "blocked" ? "🚫" : "✓";
					lines.push(`  ${icon} ${name} → ${classification}`);
				}
			} else {
				lines.push("All tools already classified.");
			}

			lines.push("");
			lines.push(`Tools — Blocked (${toolResult.blocked.size}): ${[...toolResult.blocked].sort().join(", ")}`);
			lines.push(`Tools — Allowed (${toolResult.allowed.size}): ${[...toolResult.allowed].sort().join(", ")}`);
			lines.push(`Core blocked: ${[...CORE_BLOCKED].join(", ")}`);

			lines.push("");
			lines.push(`Agents — Allowed (${agentResult.allowedAgents.size}): ${[...agentResult.allowedAgents].sort().join(", ")}`);
			lines.push(`Agents — Blocked (${agentResult.blockedAgents.size}): ${[...agentResult.blockedAgents].sort().join(", ")}`);

			if (planModeEnabled) {
				pi.setActiveTools(getPlanModeTools());
				lines.push("\nPlan mode tools updated.");
			}

			ctx.ui.notify(lines.join("\n"), "info");
		},
	});

	pi.registerShortcut(Key.shift("tab"), {
		description: "Toggle plan mode",
		handler: async (ctx) => togglePlanMode(ctx),
	});

	// --- Plan mode tool filtering ---

	pi.on("tool_call", async (event) => {
		if (!planModeEnabled) return;

		if (event.toolName === "bash") {
			const command = event.input.command as string;
			if (!isSafeCommand(command)) {
				return {
					block: true,
					reason: `Plan mode: command blocked (not allowlisted). Use Shift+Tab to disable plan mode first.\nCommand: ${command}`,
				};
			}
		}

		if (event.toolName === "subagent") {
			const input = event.input as Record<string, unknown>;
			const allowed = getAllowedAgents();
			const checkAgent = (name: string): string | null => {
				if (allowed.size === 0) return `Plan mode: no agents classified yet. Run /plan-classify first.`;
				if (!allowed.has(name)) return `Plan mode: agent "${name}" not allowed (has write tools or is unclassified). Allowed: ${[...allowed].sort().join(", ")}`;
				return null;
			};

			// Single mode
			if (typeof input.agent === "string") {
				const err = checkAgent(input.agent);
				if (err) return { block: true, reason: err };
			}
			// Parallel mode
			if (Array.isArray(input.tasks)) {
				for (const task of input.tasks) {
					const t = task as Record<string, unknown>;
					if (typeof t.agent === "string") {
						const err = checkAgent(t.agent);
						if (err) return { block: true, reason: err };
					}
				}
			}
			// Chain mode
			if (Array.isArray(input.chain)) {
				for (const step of input.chain) {
					const s = step as Record<string, unknown>;
					if (typeof s.agent === "string") {
						const err = checkAgent(s.agent);
						if (err) return { block: true, reason: err };
					}
				}
			}
		}
	});

	// --- Context filtering ---
	// Keep only the most recent plan-mode-context (like investigator pattern).
	// Old ones are historical noise. Strip plan-execution-context when not executing.

	pi.on("context", async (event) => {
		let lastPlanContextIdx = -1;
		const messages = event.messages;

		for (let i = messages.length - 1; i >= 0; i--) {
			const msg = messages[i] as typeof messages[number] & { customType?: string };
			if (msg.customType === "plan-mode-context") {
				lastPlanContextIdx = i;
				break;
			}
		}

		return {
			messages: messages.filter((m, i) => {
				const msg = m as typeof m & { customType?: string };
				if (msg.customType === "plan-mode-context" && i !== lastPlanContextIdx) return false;
				if (msg.customType === "plan-execution-context" && !executionMode) return false;
				return true;
			}),
		};
	});

	// --- System prompt injection ---

	pi.on("before_agent_start", async () => {
		if (planModeEnabled) {
			const topicLine = planTopic ? `\nTopic: "${planTopic}"` : "";
			const blocked = getBlockedTools();
			const blockedList = [...blocked].sort().join(", ");
			const allowed = getAllowedAgents();
			const allowedList = allowed.size > 0 ? [...allowed].sort().join(", ") : "(none classified — run /plan-classify)";
			return {
				message: {
					customType: "plan-mode-context",
					content: `[PLAN MODE ACTIVE]${topicLine}
You are in plan mode — a read-only exploration mode for safe code analysis.

Restrictions:
- Blocked tools: ${blockedList} (file modifications and dangerous operations disabled)
- All other tools are available for exploration (search, query, read, etc.)
- Bash is restricted to an allowlist of read-only commands
- Subagent: allowed agents: ${allowedList}. Agents with write tools (edit, write) are blocked.

Use subagent to dispatch read-only agents for parallel research tasks.
Use the supervisor skill (/skill:supervisor) for complex multi-step work — it will only dispatch allowed agents in plan mode.
Use the ask tool for clarifying questions with the user before planning.

Produce a structured plan with these sections:
- **Context** — what exists today and why it needs to change
- **Approach** — high-level strategy
- **Files to Change** — specific files and what changes
- **Testing Strategy** — how to verify
- **Open Questions** — anything unresolved

After your plan:
1. Call register_plan_steps with an array of concise, actionable step descriptions (implementation steps only).
2. Call save_plan with the full plan markdown content to persist it and open a preview.

Do NOT attempt to make changes — just describe what you would do.`,
					display: false,
				},
			};
		}

		if (executionMode && todoItems.length > 0) {
			const remaining = todoItems.filter((t) => !t.completed);
			if (remaining.length === 0) return;

			const todoList = remaining.map((t) => `${t.step}. ${t.text}`).join("\n");
			const planRef = planTopic ? `\nPlan file: .pi/plans/${slugify(planTopic)}.md` : "";
			return {
				message: {
					customType: "plan-execution-context",
					content: `[EXECUTING PLAN - Full tool access enabled]${planRef}

Remaining steps:
${todoList}

Execute each step in order.
After completing a step, call complete_plan_step with the step number.`,
					display: false,
				},
			};
		}
	});

	// --- Progress tracking ---

	function checkAllComplete(ctx: ExtensionContext): boolean {
		if (todoItems.length === 0 || !todoItems.every((t) => t.completed)) return false;

		todoItems = [];
		if (executionMode) {
			executionMode = false;
			restoreAllTools();
			clearHeader(ctx);
		}
		updateStatus(ctx);
		ctx.ui.setWidget("plan-todos", undefined);
		persistState();
		return true;
	}

	pi.on("turn_end", async (event, ctx) => {
		if (todoItems.length === 0) return;
		if (!planModeEnabled && !executionMode) return;
		if (!isAssistantMessage(event.message)) return;

		const text = getTextContent(event.message);
		if (markCompletedSteps(text, todoItems) > 0) {
			updateStatus(ctx);
			updateTodoDisplay(ctx);
			if (checkAllComplete(ctx)) return;
		}
		persistState();
	});

	// --- Plan completion (agent_end) ---

	pi.on("agent_end", async (event, ctx) => {
		// Scan all assistant messages for DONE tags
		if (todoItems.length > 0 && (planModeEnabled || executionMode)) {
			const allText = event.messages
				.filter(isAssistantMessage)
				.map(getTextContent)
				.join("\n");
			if (markCompletedSteps(allText, todoItems) > 0) {
				updateStatus(ctx);
				updateTodoDisplay(ctx);
			}
		}

		if (checkAllComplete(ctx)) return;

		// Reset per-turn flag
		const alreadySaved = planSavedThisTurn;
		planSavedThisTurn = false;

		if (!planModeEnabled) return;
		if (alreadySaved) return;

		// Fallback: write plan file if save_plan wasn't called
		const lastMsg = [...event.messages].reverse().find(isAssistantMessage);
		if (!lastMsg || lastMsg.stopReason === "aborted" || lastMsg.stopReason === "error") return;

		if (planTopic) {
			const fullPlanText = getTextContent(lastMsg);
			if (fullPlanText) {
				try {
					const filePath = writePlanFile(ctx.cwd, planTopic, `# Plan: ${planTopic}\n\n${fullPlanText}`);
					ctx.ui.notify(`Plan saved to ${filePath} (fallback — use save_plan tool next time)`, "info");
				} catch {
					// non-fatal
				}
			}
		}
	});

	// --- Session lifecycle ---

	pi.on("session_start", async (_event, ctx) => {
		restoreState(ctx);

		if (pi.getFlag("plan") === true && !planModeEnabled) {
			planModeEnabled = true;
			applyUI(ctx);
			persistState();
		}
	});

	pi.on("session_switch", async (_event, ctx) => restoreState(ctx));
	pi.on("session_fork", async (_event, ctx) => restoreState(ctx));
	pi.on("session_tree", async (_event, ctx) => restoreState(ctx));
}

