/**
 * Git Guardian Extension
 *
 * Intercepts destructive git operations and requires confirmation.
 * Gates: commit, force push, rebase, reset --hard, amend, branch -D
 *
 * For commits: shows staged diff stat and extracted commit message.
 * Offers "Edit message" option to rewrite the commit message.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { registerGuardian } from "../lib/guardian/register.js";
import { commitGuardian, destructiveGuardian } from "./review.js";

export default function gitGuardianExtension(pi: ExtensionAPI) {
	registerGuardian(pi, commitGuardian);
	registerGuardian(pi, destructiveGuardian);
}
