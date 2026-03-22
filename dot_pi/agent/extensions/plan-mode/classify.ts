import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

const EXTENSION_DIR = path.join(os.homedir(), ".pi", "agent", "extensions", "plan-mode");

export const CORE_BLOCKED = new Set(["edit", "write"]);

interface BlocklistData {
	blocked: string[];
	allowed: string[];
	blockedAgents: string[];
	allowedAgents: string[];
	lastClassified: string;
}

export interface ToolInput {
	name: string;
	description?: string;
}

const BLOCK_SIGNALS = [
	/\brun\b/i,
	/\bexecute\b/i,
	/\bstart\b/i,
	/\bspawn\b/i,
	/\bstop\b/i,
	/\bkill\b/i,
	/\bterminate\b/i,
	/\bdeploy\b/i,
	/\bpublish\b/i,
	/\bsend\b/i,
	/\bpost\b/i,
	/\bcreate\b/i,
	/\bdelete\b/i,
	/\bremove\b/i,
	/\bdestroy\b/i,
	/\bupdate\b/i,
	/\bmodify\b/i,
	/\bmutate\b/i,
	/\boverwrite\b/i,
	/\binstall\b/i,
	/\buninstall\b/i,
	/\bdelegate\b/i,
	/\bsubagent\b/i,
];

const ALLOW_SIGNALS = [
	/\bread\b/i,
	/\bsearch\b/i,
	/\blist\b/i,
	/\bget\b/i,
	/\bquery\b/i,
	/\bfetch\b/i,
	/\bfind\b/i,
	/\bshow\b/i,
	/\bview\b/i,
	/\binspect\b/i,
	/\bcheck\b/i,
	/\bdocs?\b/i,
	/\bmetadata\b/i,
	/\bprofile\b/i,
	/\bhistory\b/i,
	/\banalyze\b/i,
	/\baudit\b/i,
	/\bstatus\b/i,
	/\blog\b/i,
	/\bstats\b/i,
	/\bbrowse\b/i,
	/\blookup\b/i,
	/\bdescribe\b/i,
	/\bwait\b/i,
	/\bappend\b/i,
	/\bsetup\b/i,
	/\bcanvas\b/i,
	/\bthread\b/i,
];

export function classifyTool(name: string, description: string): "blocked" | "allowed" {
	if (CORE_BLOCKED.has(name)) return "blocked";

	const text = `${name} ${description}`;

	let blockScore = 0;
	let allowScore = 0;

	for (const p of BLOCK_SIGNALS) {
		if (p.test(text)) blockScore++;
	}
	for (const p of ALLOW_SIGNALS) {
		if (p.test(text)) allowScore++;
	}

	if (blockScore > allowScore) return "blocked";
	return "allowed";
}

function blocklistFilePath(): string {
	return path.join(EXTENSION_DIR, "blocklist.json");
}

export function loadBlocklist(): { blocked: Set<string>; allowed: Set<string>; blockedAgents: Set<string>; allowedAgents: Set<string> } {
	try {
		const raw = fs.readFileSync(blocklistFilePath(), "utf-8");
		const data = JSON.parse(raw) as BlocklistData;
		return {
			blocked: new Set(data.blocked ?? []),
			allowed: new Set(data.allowed ?? []),
			blockedAgents: new Set(data.blockedAgents ?? []),
			allowedAgents: new Set(data.allowedAgents ?? []),
		};
	} catch {
		return { blocked: new Set(), allowed: new Set(), blockedAgents: new Set(), allowedAgents: new Set() };
	}
}

export function saveBlocklist(blocked: Set<string>, allowed: Set<string>, blockedAgents?: Set<string>, allowedAgents?: Set<string>): void {
	const existing = loadBlocklist();
	const data: BlocklistData = {
		blocked: [...blocked].sort(),
		allowed: [...allowed].sort(),
		blockedAgents: [...(blockedAgents ?? existing.blockedAgents)].sort(),
		allowedAgents: [...(allowedAgents ?? existing.allowedAgents)].sort(),
		lastClassified: new Date().toISOString().slice(0, 10),
	};
	fs.writeFileSync(blocklistFilePath(), `${JSON.stringify(data, null, 2)}\n`, "utf-8");
}

export interface ClassifyResult {
	blocked: Set<string>;
	allowed: Set<string>;
	newlyClassified: Array<{ name: string; classification: "blocked" | "allowed" }>;
}

export function classifyAllTools(allTools: ToolInput[]): ClassifyResult {
	const { blocked, allowed } = loadBlocklist();
	const newlyClassified: ClassifyResult["newlyClassified"] = [];

	for (const tool of allTools) {
		if (CORE_BLOCKED.has(tool.name)) continue;
		if (blocked.has(tool.name) || allowed.has(tool.name)) continue;

		const classification = classifyTool(tool.name, tool.description ?? "");
		if (classification === "blocked") {
			blocked.add(tool.name);
		} else {
			allowed.add(tool.name);
		}
		newlyClassified.push({ name: tool.name, classification });
	}

	return { blocked, allowed, newlyClassified };
}

export function getBlockedTools(): Set<string> {
	const { blocked } = loadBlocklist();
	return new Set([...CORE_BLOCKED, ...blocked]);
}

export function getUnclassifiedTools(allTools: ToolInput[]): string[] {
	const { blocked, allowed } = loadBlocklist();
	return allTools
		.map((t) => t.name)
		.filter((name) => !CORE_BLOCKED.has(name) && !blocked.has(name) && !allowed.has(name));
}

const AGENTS_DIR = path.join(os.homedir(), ".pi", "agent", "agents");

interface AgentInfo {
	name: string;
	tools: string[] | null;
}

function parseAgentFrontmatter(content: string): { name: string; tools: string[] | null } | null {
	const match = content.match(/^---\n([\s\S]*?)\n---/);
	if (!match) return null;

	const frontmatter = match[1];
	const nameMatch = frontmatter.match(/^name:\s*(.+)$/m);
	const toolsMatch = frontmatter.match(/^tools:\s*(.+)$/m);

	if (!nameMatch) return null;

	const name = nameMatch[1].trim();
	const tools = toolsMatch ? toolsMatch[1].split(",").map((t) => t.trim()).filter(Boolean) : null;

	return { name, tools };
}

export function discoverAgents(): AgentInfo[] {
	try {
		const files = fs.readdirSync(AGENTS_DIR).filter((f) => f.endsWith(".md"));
		const agents: AgentInfo[] = [];

		for (const file of files) {
			try {
				const content = fs.readFileSync(path.join(AGENTS_DIR, file), "utf-8");
				const parsed = parseAgentFrontmatter(content);
				if (parsed) agents.push(parsed);
			} catch {
				// skip unreadable files
			}
		}

		return agents;
	} catch {
		return [];
	}
}

export function classifyAgent(agent: AgentInfo, blockedTools: Set<string>): "blocked" | "allowed" {
	if (!agent.tools) return "blocked";
	for (const tool of agent.tools) {
		if (blockedTools.has(tool)) return "blocked";
	}
	return "allowed";
}

export interface AgentClassifyResult {
	blockedAgents: Set<string>;
	allowedAgents: Set<string>;
	newlyClassified: Array<{ name: string; classification: "blocked" | "allowed" }>;
}

export function classifyAllAgents(blockedTools: Set<string>): AgentClassifyResult {
	const agents = discoverAgents();
	const blockedAgents = new Set<string>();
	const allowedAgents = new Set<string>();
	const newlyClassified: AgentClassifyResult["newlyClassified"] = [];

	for (const agent of agents) {
		const classification = classifyAgent(agent, blockedTools);
		if (classification === "blocked") {
			blockedAgents.add(agent.name);
		} else {
			allowedAgents.add(agent.name);
		}
		newlyClassified.push({ name: agent.name, classification });
	}

	return { blockedAgents, allowedAgents, newlyClassified };
}

export function getAllowedAgents(): Set<string> {
	const { allowedAgents } = loadBlocklist();
	return allowedAgents;
}
