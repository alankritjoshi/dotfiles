/**
 * Git command parsing — extract commit messages and diff stats.
 */

import { execSync } from "node:child_process";

export function getDiffStat(cwd: string): string {
	try {
		return execSync("git diff --cached --stat", { cwd, encoding: "utf-8", timeout: 5000 }).trim();
	} catch {
		return "(no staged changes)";
	}
}

export function extractCommitMessage(command: string): string | null {
	const match = command.match(/\bgit\s+commit\b.*-m\s+(?:"([^"]*(?:\\.[^"]*)*)"|'([^']*)'|(\S+))/);
	if (!match) return null;
	return (match[1] ?? match[2] ?? match[3] ?? "").replace(/\\"/g, '"');
}

export function replaceCommitMessage(command: string, newMessage: string): string {
	const escaped = newMessage.replace(/"/g, '\\"');
	return command.replace(
		/(-m\s+)(?:"[^"]*(?:\\.[^"]*)*"|'[^']*'|\S+)/,
		`$1"${escaped}"`,
	);
}
