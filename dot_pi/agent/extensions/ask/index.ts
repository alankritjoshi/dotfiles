/**
 * Ask Tool Extension
 *
 * Registers an `ask` tool that lets the agent ask the user a
 * question mid-turn via a UI prompt. The agent gets the answer
 * immediately and can continue working in the same turn —
 * no full turn cycle needed.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { Text } from "@mariozechner/pi-tui";

export default function askExtension(pi: ExtensionAPI) {
	pi.registerTool({
		name: "ask",
		label: "Ask User",
		description:
			"Ask the user a question and get an immediate answer without ending the current turn.",
		promptSnippet:
			"Ask the user a clarifying question mid-turn. Use when you need input to continue.",
		promptGuidelines: [
			"Use ask when you need a quick answer to continue working — not for open-ended discussion.",
			"Prefer ask over stopping and asking inline when you can continue the task after getting the answer.",
		],
		parameters: Type.Object({
			question: Type.String({
				description: "The question to ask the user",
			}),
			options: Type.Optional(
				Type.Array(Type.String(), {
					description:
						"Optional list of choices. If provided, user picks one. If omitted, user types a free-form answer.",
				}),
			),
		}),
		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			if (!ctx.hasUI) {
				return {
					content: [
						{
							type: "text",
							text: "Cannot ask — no UI available. Make your best judgment and proceed.",
						},
					],
				};
			}

			let answer: string | undefined;

			if (params.options?.length) {
				answer = await ctx.ui.select(params.question, params.options);
			} else {
				answer = await ctx.ui.editor(params.question, "");
			}

			if (!answer?.trim()) {
				return {
					content: [
						{
							type: "text",
							text: "User dismissed the question. Proceed with your best judgment.",
						},
					],
					details: { dismissed: true },
				};
			}

			return {
				content: [{ type: "text", text: answer.trim() }],
				details: { answered: true },
			};
		},

		renderCall(args, theme) {
			const a = args as { question?: string; options?: string[] };
			let text = theme.fg("toolTitle", theme.bold("ask "));
			const q = a.question ?? "";
			const preview = q.length > 60 ? `${q.slice(0, 57)}...` : q;
			text += theme.fg("muted", preview);
			if (a.options?.length) {
				text += theme.fg("dim", ` (${a.options.length} choices)`);
			}
			return new Text(text, 0, 0);
		},

		renderResult(result, _options, theme) {
			const d = result.details as
				| { dismissed?: boolean; answered?: boolean }
				| undefined;
			if (d?.dismissed) {
				return new Text(theme.fg("warning", "dismissed"), 0, 0);
			}
			const t = result.content?.[0];
			const answer = t && "text" in t ? t.text : "";
			const preview = answer.length > 80 ? `${answer.slice(0, 77)}...` : answer;
			return new Text(theme.fg("success", "→ ") + preview, 0, 0);
		},
	});
}
