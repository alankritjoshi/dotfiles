import { describe, expect, test } from "bun:test";
import { classifyTool, classifyAgent } from "./classify.js";

describe("classifyTool", () => {
	test("core blocked tools", () => {
		expect(classifyTool("edit", "Edit a file")).toBe("blocked");
		expect(classifyTool("write", "Write a file")).toBe("blocked");
	});

	test("blocks dangerous extension tools", () => {
		expect(classifyTool("bg_run", "Run a command in the background")).toBe("blocked");
		expect(classifyTool("bg_stop", "Stop a background job")).toBe("blocked");
		expect(classifyTool("subagent", "Delegate a task to a subagent")).toBe("blocked");
		expect(classifyTool("memory_update", "Update a memory bank file")).toBe("blocked");
	});

	test("allows read-only extension tools", () => {
		expect(classifyTool("grokt_search", "Search code across repositories")).toBe("allowed");
		expect(classifyTool("grokt_bulk_search", "Bulk search code")).toBe("allowed");
		expect(classifyTool("grokt_get_file", "Get a file from indexed repos")).toBe("allowed");
		expect(classifyTool("grokt_stats", "Get index stats")).toBe("allowed");
		expect(classifyTool("slack_search", "Search Slack messages")).toBe("allowed");
		expect(classifyTool("slack_thread", "Fetch a Slack thread")).toBe("allowed");
		expect(classifyTool("slack_profile", "Get user profile")).toBe("allowed");
		expect(classifyTool("slack_history", "Fetch channel history")).toBe("allowed");
		expect(classifyTool("slack_canvas", "Fetch a Slack canvas")).toBe("allowed");
	});

	test("allows observe tools", () => {
		expect(classifyTool("observe_query", "Run a structured query")).toBe("allowed");
		expect(classifyTool("observe_datasets", "List datasets")).toBe("allowed");
		expect(classifyTool("observe_error_groups", "List error groups")).toBe("allowed");
		expect(classifyTool("observe_instant_query", "PromQL instant query")).toBe("allowed");
		expect(classifyTool("observe_metrics", "List metrics")).toBe("allowed");
		expect(classifyTool("observe_ai_docs", "AI documentation")).toBe("allowed");
	});

	test("allows data portal tools", () => {
		expect(classifyTool("data_portal_search", "Search the data platform")).toBe("allowed");
		expect(classifyTool("data_portal_metadata", "Look up table metadata")).toBe("allowed");
		expect(classifyTool("data_portal_docs", "Load documentation")).toBe("allowed");
		expect(classifyTool("data_portal_query", "Execute a read-only BigQuery query")).toBe("allowed");
		expect(classifyTool("data_portal_analyze", "Analyze data with Python")).toBe("allowed");
		expect(classifyTool("data_portal_setup", "Check dependencies and auth setup")).toBe("allowed");
	});

	test("allows background job read tools", () => {
		expect(classifyTool("bg_list", "List background jobs")).toBe("allowed");
		expect(classifyTool("bg_log", "Read background job logs")).toBe("allowed");
		expect(classifyTool("bg_wait", "Wait for a background job")).toBe("allowed");
	});

	test("allows memory read tools", () => {
		expect(classifyTool("memory_read", "Read a memory bank file")).toBe("allowed");
		expect(classifyTool("memory_list", "List memory bank files")).toBe("allowed");
		expect(classifyTool("memory_append", "Append to a memory bank file")).toBe("allowed");
	});

	test("allows web search tools", () => {
		expect(classifyTool("perplexity_search", "Search the web")).toBe("allowed");
		expect(classifyTool("perplexity_fetch", "Fetch a URL")).toBe("allowed");
	});

	test("allows utility tools", () => {
		expect(classifyTool("ask", "Ask the user a question")).toBe("allowed");
		expect(classifyTool("log_finding", "Record an investigation finding")).toBe("allowed");
		expect(classifyTool("read_output_chunk", "Read truncated output")).toBe("allowed");
		expect(classifyTool("search_output", "Search truncated output")).toBe("allowed");
	});

	test("defaults unknown tools to allowed", () => {
		expect(classifyTool("some_new_tool", "Does something neutral")).toBe("allowed");
	});

	test("block wins when block signals dominate", () => {
		expect(classifyTool("deploy_thing", "Deploy and publish artifacts")).toBe("blocked");
		expect(classifyTool("file_creator", "Create new files on disk")).toBe("blocked");
	});
});

describe("classifyAgent", () => {
	const blockedTools = new Set(["edit", "write", "bg_run", "bg_stop"]);

	test("allows agent with only read-only tools", () => {
		expect(classifyAgent({ name: "scout", tools: ["read", "grep", "find", "ls"] }, blockedTools)).toBe("allowed");
	});

	test("allows agent with bash but no write tools", () => {
		expect(classifyAgent({ name: "scout", tools: ["read", "grep", "find", "ls", "bash"] }, blockedTools)).toBe("allowed");
	});

	test("blocks agent with edit tool", () => {
		expect(classifyAgent({ name: "executor", tools: ["read", "edit", "write", "bash"] }, blockedTools)).toBe("blocked");
	});

	test("blocks agent with write tool", () => {
		expect(classifyAgent({ name: "writer", tools: ["read", "write"] }, blockedTools)).toBe("blocked");
	});

	test("blocks agent with no tools field (unrestricted)", () => {
		expect(classifyAgent({ name: "worker", tools: null }, blockedTools)).toBe("blocked");
	});

	test("allows agent with research tools only", () => {
		expect(classifyAgent({ name: "researcher", tools: ["vault_search", "slack_search", "grokt_search", "read", "grep"] }, blockedTools)).toBe("allowed");
	});

	test("blocks agent with blocked extension tool", () => {
		expect(classifyAgent({ name: "bg-manager", tools: ["bg_run", "bg_stop", "read"] }, blockedTools)).toBe("blocked");
	});
});
