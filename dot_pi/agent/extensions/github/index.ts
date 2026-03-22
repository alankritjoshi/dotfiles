import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { Text } from "@mariozechner/pi-tui";

export default function (pi: ExtensionAPI) {
  async function gh(
    args: string[],
    signal?: AbortSignal,
  ): Promise<string> {
    const result = await pi.exec("gh", args, { signal, timeout: 30000 });
    if (result.code !== 0) {
      const msg = result.stderr.trim() || result.stdout.trim() || `gh exited with code ${result.code}`;
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

  // ─── gh_issue_view ────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gh_issue_view",
    label: "GitHub — View Issue",
    description:
      "View a GitHub issue: title, body, labels, assignees, comments. " +
      "Provide a URL or (owner + repo + number).",
    parameters: Type.Object({
      url: Type.Optional(Type.String({ description: "GitHub issue URL (e.g. https://github.com/owner/repo/issues/123)" })),
      owner: Type.Optional(Type.String({ description: "Repository owner" })),
      repo: Type.Optional(Type.String({ description: "Repository name" })),
      number: Type.Optional(Type.Number({ description: "Issue number" })),
      comments: Type.Optional(Type.Boolean({ description: "Include comments (default: true)" })),
    }),
    async execute(_id, params, signal) {
      try {
        const ref = resolveRef(params);
        const includeComments = params.comments !== false;

        const fields = "number,title,state,body,labels,assignees,milestone,createdAt,author,url";
        const raw = await gh(
          ["issue", "view", String(ref.number), "--repo", `${ref.owner}/${ref.repo}`, "--json", fields],
          signal,
        );
        const issue = JSON.parse(raw);

        const lines: string[] = [
          `# #${issue.number} — ${issue.title}`,
          `State: ${issue.state} | Author: ${issue.author?.login ?? "unknown"} | Created: ${issue.createdAt}`,
          issue.labels?.length ? `Labels: ${issue.labels.map((l: any) => l.name).join(", ")}` : null,
          issue.assignees?.length ? `Assignees: ${issue.assignees.map((a: any) => a.login).join(", ")}` : null,
          issue.milestone ? `Milestone: ${issue.milestone.title}` : null,
          `URL: ${issue.url}`,
          "",
          issue.body || "(no description)",
        ].filter((l): l is string => l !== null);

        if (includeComments) {
          const commentsRaw = await gh(
            ["issue", "view", String(ref.number), "--repo", `${ref.owner}/${ref.repo}`, "--json", "comments"],
            signal,
          );
          const { comments } = JSON.parse(commentsRaw);
          if (comments?.length) {
            lines.push("", `--- ${comments.length} comment(s) ---`);
            for (const c of comments) {
              lines.push("", `**${c.author?.login ?? "unknown"}** (${c.createdAt}):`);
              lines.push(c.body);
            }
          }
        }

        return ok(lines.join("\n"), { owner: ref.owner, repo: ref.repo, number: issue.number, state: issue.state });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      const label = args.url || `${args.owner}/${args.repo}#${args.number}`;
      return new Text(theme.fg("toolTitle", theme.bold("GitHub — View Issue ")) + theme.fg("muted", String(label)), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error || !d?.owner) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ ") + `${d.owner}/${d.repo}#${d.number} — ${d.state}`, 0, 0);
    },
  });

  // ─── gh_issue_list ────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gh_issue_list",
    label: "GitHub — List Issues",
    description:
      "List or search issues in a GitHub repo. Returns title, number, state, labels, assignee.",
    parameters: Type.Object({
      owner: Type.String({ description: "Repository owner" }),
      repo: Type.String({ description: "Repository name" }),
      state: Type.Optional(Type.String({ description: "Filter by state: open, closed, all (default: open)" })),
      label: Type.Optional(Type.String({ description: "Filter by label" })),
      assignee: Type.Optional(Type.String({ description: "Filter by assignee" })),
      search: Type.Optional(Type.String({ description: "Search query" })),
      limit: Type.Optional(Type.Number({ description: "Max results (default: 20, max: 100)" })),
    }),
    async execute(_id, params, signal) {
      try {
        const limit = Math.min(params.limit ?? 20, 100);
        const args = [
          "issue", "list",
          "--repo", `${params.owner}/${params.repo}`,
          "--json", "number,title,state,labels,assignees,createdAt,author",
          "--limit", String(limit),
        ];
        if (params.state) args.push("--state", params.state);
        if (params.label) args.push("--label", params.label);
        if (params.assignee) args.push("--assignee", params.assignee);
        if (params.search) args.push("--search", params.search);

        const raw = await gh(args, signal);
        const issues = JSON.parse(raw);

        if (!issues.length) return ok("No issues found.", { owner: params.owner, repo: params.repo, count: 0 });

        const lines = issues.map((i: any) => {
          const labels = i.labels?.map((l: any) => l.name).join(", ");
          const assignee = i.assignees?.[0]?.login ?? "";
          return `#${i.number}\t${i.state}\t${i.title}${labels ? `\t[${labels}]` : ""}${assignee ? `\t@${assignee}` : ""}`;
        });

        return ok(
          `${issues.length} issue(s) in ${params.owner}/${params.repo}:\n\n${lines.join("\n")}`,
          { owner: params.owner, repo: params.repo, count: issues.length },
        );
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      const filters = [args.state, args.label, args.search].filter(Boolean).join(", ");
      return new Text(
        theme.fg("toolTitle", theme.bold("GitHub — List Issues ")) +
        theme.fg("muted", `${args.owner}/${args.repo}`) +
        (filters ? theme.fg("dim", ` (${filters})`) : ""),
        0, 0,
      );
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error || d?.count == null) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ ") + `${d.count} issues`, 0, 0);
    },
  });

  // ─── gh_pr_view ───────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gh_pr_view",
    label: "GitHub — View PR",
    description:
      "View a pull request: title, body, diff stats, review status, checks. " +
      "Provide a URL or (owner + repo + number).",
    parameters: Type.Object({
      url: Type.Optional(Type.String({ description: "GitHub PR URL" })),
      owner: Type.Optional(Type.String({ description: "Repository owner" })),
      repo: Type.Optional(Type.String({ description: "Repository name" })),
      number: Type.Optional(Type.Number({ description: "PR number" })),
      comments: Type.Optional(Type.Boolean({ description: "Include review comments (default: false)" })),
    }),
    async execute(_id, params, signal) {
      try {
        const ref = resolveRef(params);
        const fields = "number,title,state,body,author,createdAt,baseRefName,headRefName," +
          "additions,deletions,changedFiles,mergeable,reviewDecision,statusCheckRollup,url,labels,assignees";

        const raw = await gh(
          ["pr", "view", String(ref.number), "--repo", `${ref.owner}/${ref.repo}`, "--json", fields],
          signal,
        );
        const pr = JSON.parse(raw);

        const checks = pr.statusCheckRollup ?? [];
        const checkSummary: Record<string, number> = {};
        for (const c of checks) checkSummary[c.conclusion || c.status || "pending"] = (checkSummary[c.conclusion || c.status || "pending"] || 0) + 1;

        const lines: string[] = [
          `# PR #${pr.number} — ${pr.title}`,
          `State: ${pr.state} | Author: ${pr.author?.login ?? "unknown"} | Created: ${pr.createdAt}`,
          `Branch: ${pr.headRefName} → ${pr.baseRefName}`,
          `Changes: +${pr.additions} -${pr.deletions} (${pr.changedFiles} files)`,
          `Mergeable: ${pr.mergeable} | Review: ${pr.reviewDecision || "none"}`,
          pr.labels?.length ? `Labels: ${pr.labels.map((l: any) => l.name).join(", ")}` : null,
          pr.assignees?.length ? `Assignees: ${pr.assignees.map((a: any) => a.login).join(", ")}` : null,
          Object.keys(checkSummary).length ? `Checks: ${Object.entries(checkSummary).map(([s, n]) => `${n} ${s}`).join(", ")}` : null,
          `URL: ${pr.url}`,
          "",
          pr.body || "(no description)",
        ].filter((l): l is string => l !== null);

        if (params.comments) {
          const commentsArgs = ["pr", "view", String(ref.number), "--repo", `${ref.owner}/${ref.repo}`, "--json", "comments,reviews"];
          const commentsRaw = await gh(commentsArgs, signal);
          const data = JSON.parse(commentsRaw);
          const allComments = [
            ...(data.comments || []),
            ...(data.reviews || []).filter((r: any) => r.body),
          ].sort((a: any, b: any) => a.createdAt?.localeCompare(b.createdAt));

          if (allComments.length) {
            lines.push("", `--- ${allComments.length} comment(s)/review(s) ---`);
            for (const c of allComments) {
              const author = c.author?.login ?? "unknown";
              const state = c.state ? ` [${c.state}]` : "";
              lines.push("", `**${author}**${state} (${c.createdAt ?? c.submittedAt}):`);
              lines.push(c.body);
            }
          }
        }

        return ok(lines.join("\n"), {
          owner: ref.owner, repo: ref.repo, number: pr.number,
          state: pr.state, review: pr.reviewDecision || "none",
        });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      const label = args.url || `${args.owner}/${args.repo}#${args.number}`;
      return new Text(theme.fg("toolTitle", theme.bold("GitHub — View PR ")) + theme.fg("muted", String(label)), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error || !d?.number) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ ") + `PR #${d.number} — ${d.state} (${d.review})`, 0, 0);
    },
  });

  // ─── gh_pr_list ───────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gh_pr_list",
    label: "GitHub — List PRs",
    description:
      "List or search pull requests in a GitHub repo.",
    parameters: Type.Object({
      owner: Type.String({ description: "Repository owner" }),
      repo: Type.String({ description: "Repository name" }),
      state: Type.Optional(Type.String({ description: "Filter by state: open, closed, merged, all (default: open)" })),
      label: Type.Optional(Type.String({ description: "Filter by label" })),
      author: Type.Optional(Type.String({ description: "Filter by author" })),
      search: Type.Optional(Type.String({ description: "Search query" })),
      limit: Type.Optional(Type.Number({ description: "Max results (default: 20, max: 100)" })),
    }),
    async execute(_id, params, signal) {
      try {
        const limit = Math.min(params.limit ?? 20, 100);
        const args = [
          "pr", "list",
          "--repo", `${params.owner}/${params.repo}`,
          "--json", "number,title,state,author,headRefName,baseRefName,createdAt,reviewDecision,labels",
          "--limit", String(limit),
        ];
        if (params.state) args.push("--state", params.state);
        if (params.label) args.push("--label", params.label);
        if (params.author) args.push("--author", params.author);
        if (params.search) args.push("--search", params.search);

        const raw = await gh(args, signal);
        const prs = JSON.parse(raw);

        if (!prs.length) return ok("No PRs found.", { owner: params.owner, repo: params.repo, count: 0 });

        const lines = prs.map((p: any) => {
          const review = p.reviewDecision ? ` (${p.reviewDecision})` : "";
          return `#${p.number}\t${p.state}\t${p.title}\t@${p.author?.login ?? "?"}${review}`;
        });

        return ok(
          `${prs.length} PR(s) in ${params.owner}/${params.repo}:\n\n${lines.join("\n")}`,
          { owner: params.owner, repo: params.repo, count: prs.length },
        );
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      const filters = [args.state, args.author, args.search].filter(Boolean).join(", ");
      return new Text(
        theme.fg("toolTitle", theme.bold("GitHub — List PRs ")) +
        theme.fg("muted", `${args.owner}/${args.repo}`) +
        (filters ? theme.fg("dim", ` (${filters})`) : ""),
        0, 0,
      );
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error || d?.count == null) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ ") + `${d.count} PRs`, 0, 0);
    },
  });

  // ─── gh_repo_view ─────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gh_repo_view",
    label: "GitHub — View Repo",
    description:
      "Get repository info: description, stars, language, recent activity.",
    parameters: Type.Object({
      owner: Type.String({ description: "Repository owner" }),
      repo: Type.String({ description: "Repository name" }),
    }),
    async execute(_id, params, signal) {
      try {
        const fields = "name,owner,description,url,defaultBranchRef,stargazerCount," +
          "forkCount,isArchived,isPrivate,primaryLanguage,pushedAt,createdAt";
        const raw = await gh(
          ["repo", "view", `${params.owner}/${params.repo}`, "--json", fields],
          signal,
        );
        const r = JSON.parse(raw);

        const lines = [
          `# ${r.owner?.login ?? params.owner}/${r.name}`,
          r.description || "(no description)",
          "",
          `Default branch: ${r.defaultBranchRef?.name ?? "unknown"}`,
          `Language: ${r.primaryLanguage?.name ?? "unknown"}`,
          `Stars: ${r.stargazerCount} | Forks: ${r.forkCount}`,
          `Private: ${r.isPrivate} | Archived: ${r.isArchived}`,
          `Last push: ${r.pushedAt}`,
          `URL: ${r.url}`,
        ];

        return ok(lines.join("\n"), { owner: params.owner, repo: params.repo });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      return new Text(theme.fg("toolTitle", theme.bold("GitHub — View Repo ")) + theme.fg("muted", `${args.owner}/${args.repo}`), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error || !d?.owner) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      return new Text(theme.fg("success", "✓ ") + `${d.owner}/${d.repo}`, 0, 0);
    },
  });

}

// ─── Helpers ────────────────────────────────────────────────────────────────

function resolveRef(params: {
  url?: string; owner?: string; repo?: string; number?: number;
}): { owner: string; repo: string; number: number } {
  if (params.url) {
    // Standard: github.com/owner/repo/issues/123 or github.com/owner/repo/pull/123
    const full = params.url.match(/github\.com\/([^/]+)\/([^/]+)\/(issues|pull)\/(\d+)/);
    if (full) return { owner: full[1], repo: full[2], number: parseInt(full[4], 10) };

    // Repo named "issues" or "pull": github.com/owner/issues/123
    // The second segment doubles as both repo name and path keyword.
    const short = params.url.match(/github\.com\/([^/]+)\/(issues|pull)\/(\d+)/);
    if (short) {
      return { owner: short[1], repo: short[2], number: parseInt(short[3], 10) };
    }

    throw new Error(`Cannot parse GitHub URL: ${params.url}`);
  }
  if (params.owner && params.repo && params.number !== undefined) {
    return { owner: params.owner, repo: params.repo, number: params.number };
  }
  throw new Error("Provide either url, or all of (owner, repo, number).");
}
