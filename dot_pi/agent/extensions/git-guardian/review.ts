/**
 * Git guardian reviews — commit review and destructive operation review.
 */

import type { ExtensionContext } from "@mariozechner/pi-coding-agent";
import type { CommandGuardian, GuardianResult } from "../lib/guardian/types.js";
import { extractCommitMessage, getDiffStat, replaceCommitMessage } from "./parse.js";

interface CommitParsed {
	message: string | null;
	command: string;
}

export const commitGuardian: CommandGuardian<CommitParsed> = {
	detect(command) {
		return /\bgit\s+commit\b(?!.*--fixup)/.test(command);
	},

	parse(command) {
		return {
			message: extractCommitMessage(command),
			command,
		};
	},

	async review(
		parsed: CommitParsed,
		event: { input: { command: string } },
		ctx: ExtensionContext,
	): Promise<GuardianResult> {
		const diffStat = getDiffStat(ctx.cwd);
		const messageLine = parsed.message ? `Message: ${parsed.message}` : "Message: (no -m flag)";

		const prompt = `🛡️ git commit\n\n  ${messageLine}\n\n  Staged changes:\n${diffStat.split("\n").map((l) => `    ${l}`).join("\n")}\n\nAllow?`;

		const choices = parsed.message
			? ["Yes", "Edit message", "No"]
			: ["Yes", "No"];

		const choice = await ctx.ui.select(prompt, choices);

		if (choice === "Edit message") {
			const newMessage = await ctx.ui.editor("Edit commit message:", parsed.message || "");
			if (!newMessage?.trim()) {
				return { block: true, reason: "git commit blocked — empty message" };
			}
			return { rewrite: replaceCommitMessage(event.input.command, newMessage.trim()) };
		}

		if (choice !== "Yes") {
			return { block: true, reason: "git commit blocked by user" };
		}

		return undefined;
	},
};

interface DestructiveParsed {
	label: string;
	command: string;
}

const DESTRUCTIVE_PATTERNS: { pattern: RegExp; label: string }[] = [
	{ pattern: /\bgit\s+push\s+.*--force(-with-lease)?\b/, label: "git push --force" },
	{ pattern: /\bgit\s+rebase\b/, label: "git rebase" },
	{ pattern: /\bgit\s+reset\s+--hard\b/, label: "git reset --hard" },
	{ pattern: /\bgit\s+commit\s+.*--amend\b/, label: "git commit --amend" },
	{ pattern: /\bgit\s+branch\s+.*-D\b/, label: "git branch -D" },
];

export const destructiveGuardian: CommandGuardian<DestructiveParsed> = {
	detect(command) {
		return DESTRUCTIVE_PATTERNS.some((p) => p.pattern.test(command));
	},

	parse(command) {
		const match = DESTRUCTIVE_PATTERNS.find((p) => p.pattern.test(command));
		if (!match) return null;
		return { label: match.label, command };
	},

	async review(
		parsed: DestructiveParsed,
		_event: { input: { command: string } },
		ctx: ExtensionContext,
	): Promise<GuardianResult> {
		const choice = await ctx.ui.select(
			`🛡️ ${parsed.label} detected:\n\n  ${parsed.command}\n\nAllow?`,
			["Yes", "No"],
		);

		if (choice !== "Yes") {
			return { block: true, reason: `${parsed.label} blocked by user` };
		}

		return undefined;
	},
};
