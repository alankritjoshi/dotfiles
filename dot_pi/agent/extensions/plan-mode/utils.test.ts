import { isSafeCommand, splitPipeline, stripSafeRedirects } from "./utils.js";

let passed = 0;
let failed = 0;

function assert(name: string, actual: boolean, expected: boolean): void {
	if (actual === expected) {
		passed++;
	} else {
		failed++;
		console.error(`FAIL: ${name} — expected ${expected}, got ${actual}`);
	}
}

// --- stripSafeRedirects ---
console.log("=== stripSafeRedirects ===");
assert("strips 2>/dev/null", stripSafeRedirects("curl -s url 2>/dev/null") === "curl -s url", true);
assert("strips 2>&1", stripSafeRedirects("cmd 2>&1") === "cmd", true);
assert("preserves > file.txt", stripSafeRedirects("echo foo > file.txt") === "echo foo > file.txt", true);

// --- splitPipeline ---
console.log("=== splitPipeline ===");
assert("simple pipe", JSON.stringify(splitPipeline("curl url | jq .")) === JSON.stringify(["curl url", "jq ."]), true);
assert("double pipe (||)", JSON.stringify(splitPipeline('cmd || echo "fail"')) === JSON.stringify(["cmd", 'echo "fail"']), true);
assert("&&", JSON.stringify(splitPipeline("ls && pwd")) === JSON.stringify(["ls", "pwd"]), true);
assert("pipe in quotes preserved", splitPipeline('echo "a|b"').length === 1, true);
assert("complex pipeline", splitPipeline('curl -s url | python3 -c "import sys" || echo fail').length === 3, true);

// --- isSafeCommand: originally blocked ---
console.log("=== isSafeCommand: the reported bug ===");
assert(
	"curl piped to python3 -c with 2>/dev/null",
	isSafeCommand(
		'curl -s https://api.github.com/repos/X/Y/contents/extensions 2>/dev/null | python3 -c "import sys,json;\n [print(x[\'name\']) for x in json.load(sys.stdin)]" 2>/dev/null || echo "API call failed"',
	),
	true,
);

// --- isSafeCommand: safe commands ---
console.log("=== isSafeCommand: safe ===");
assert("simple ls", isSafeCommand("ls -la"), true);
assert("grep", isSafeCommand("grep -r pattern ."), true);
assert("curl", isSafeCommand("curl -s https://example.com"), true);
assert("curl 2>/dev/null", isSafeCommand("curl -s https://example.com 2>/dev/null"), true);
assert("cat with stderr redirect", isSafeCommand("cat file.txt 2>/dev/null"), true);
assert("git status", isSafeCommand("git status"), true);
assert("git log", isSafeCommand("git log --oneline"), true);
assert("find piped to grep", isSafeCommand("find . -name '*.ts' | grep test"), true);
assert("curl | jq", isSafeCommand("curl -s url | jq .name"), true);
assert("curl | python3 -c", isSafeCommand('curl -s url | python3 -c "import json"'), true);
assert("ls && pwd", isSafeCommand("ls && pwd"), true);
assert("echo fallback", isSafeCommand('cmd_safe || echo "failed"'), false); // cmd_safe isn't allowlisted
assert("wc -l", isSafeCommand("wc -l"), true);
assert("sort | uniq", isSafeCommand("sort file | uniq -c"), true);
assert("python3 -c standalone", isSafeCommand('python3 -c "print(1+1)"'), true);
assert("node -e standalone", isSafeCommand('node -e "console.log(1)"'), true);

// --- isSafeCommand: chezmoi ---
console.log("=== isSafeCommand: chezmoi ===");
assert("chezmoi diff", isSafeCommand("chezmoi diff --no-pager"), true);
assert("chezmoi shopify diff", isSafeCommand("chezmoi --config ~/.config/chezmoi-shopify.yaml diff --no-pager"), true);
assert("chezmoi managed", isSafeCommand("chezmoi managed --no-pager"), true);
assert("chezmoi cat", isSafeCommand("chezmoi cat ~/.pi/agent/AGENTS.md"), true);
assert("chezmoi data", isSafeCommand("chezmoi data"), true);
assert("chezmoi status", isSafeCommand("chezmoi status"), true);
assert("chezmoi apply blocked", isSafeCommand("chezmoi apply"), false);
assert("chezmoi edit blocked", isSafeCommand("chezmoi edit ~/.config/fish/config.fish"), false);
assert("chezmoi add blocked", isSafeCommand("chezmoi add ~/.config/something"), false);
assert("chezmoi init blocked", isSafeCommand("chezmoi init alankritjoshi/dotfiles"), false);

// --- isSafeCommand: destructive (must block) ---
console.log("=== isSafeCommand: destructive ===");
assert("rm", isSafeCommand("rm -rf /"), false);
assert("echo > file", isSafeCommand("echo foo > file.txt"), false);
assert("cat >> file", isSafeCommand("cat foo >> file.txt"), false);
assert("sudo", isSafeCommand("sudo ls"), false);
assert("git push", isSafeCommand("git push origin main"), false);
assert("git commit", isSafeCommand("git commit -m 'test'"), false);
assert("npm install", isSafeCommand("npm install express"), false);
assert("safe pipe to rm", isSafeCommand("find . -name '*.tmp' | xargs rm"), false);
assert("curl to file via redirect", isSafeCommand("curl -s url > output.json"), false);
assert("mv", isSafeCommand("mv a.txt b.txt"), false);
assert("kill", isSafeCommand("kill -9 1234"), false);
assert("vim", isSafeCommand("vim file.txt"), false);
assert("brew install", isSafeCommand("brew install something"), false);

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
