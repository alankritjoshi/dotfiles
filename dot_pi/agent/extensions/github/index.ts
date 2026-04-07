/**
 * GitHub Extension (slim)
 *
 * Only tools NOT provided by tool-gateway:
 * - gh_pr_checks — detailed check runs for a PR
 * - gh_pr_job_logs — CI job logs for a PR (GitHub Actions)
 * - gh_repo_view — repository metadata
 *
 * For issues and PRs, use tool-gateway's github_* tools.
 */

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

  // ─── gh_pr_checks ─────────────────────────────────────────────────────────

  pi.registerTool({
    name: "gh_pr_checks",
    label: "GitHub — View PR Checks",
    description:
      "Get detailed check runs for a pull request. Shows status, conclusion, and details for each check. " +
      "Provide a URL or (owner + repo + number).",
    parameters: Type.Object({
      url: Type.Optional(Type.String({ description: "GitHub PR URL" })),
      owner: Type.Optional(Type.String({ description: "Repository owner" })),
      repo: Type.Optional(Type.String({ description: "Repository name" })),
      number: Type.Optional(Type.Number({ description: "PR number" })),
    }),
    async execute(_id, params, signal) {
      try {
        const ref = resolveRef(params);

        const prRaw = await gh(
          ["pr", "view", String(ref.number), "--repo", `${ref.owner}/${ref.repo}`, "--json", "number,headRefOid,headRefName,title"],
          signal,
        );
        const pr = JSON.parse(prRaw);

        const checksRaw = await gh(
          ["pr", "checks", String(ref.number), "--repo", `${ref.owner}/${ref.repo}`, "--json", "name,state,bucket,description,link,event,workflow,completedAt,startedAt"],
          signal,
        );
        const checks = JSON.parse(checksRaw);

        if (!checks.length) {
          return ok(
            `No checks found for PR #${ref.number}.`,
            { owner: ref.owner, repo: ref.repo, number: ref.number, count: 0 },
          );
        }

        const icon: Record<string, string> = { pass: "✓", fail: "✗", pending: "◐", skipping: "⊘", cancel: "⊘" };
        const lines: string[] = [
          `# Checks for PR #${ref.number} — ${pr.title}`,
          `Commit: ${(pr.headRefOid || "").slice(0, 7)} (${pr.headRefName})`,
          "",
        ];

        for (const check of checks) {
          const bucket = check.bucket || "pending";
          const name = check.name || "unknown";
          const desc = check.description ? ` — ${check.description}` : "";
          lines.push(`${icon[bucket] || "?"} ${name}${desc}`);
          if (check.link) lines.push(`  ${check.link}`);
        }

        const passCount = checks.filter((c: any) => c.bucket === "pass").length;
        const failCount = checks.filter((c: any) => c.bucket === "fail").length;
        const skippedCount = checks.filter((c: any) => c.bucket === "skipping").length;
        const pendingCount = checks.filter((c: any) => c.bucket === "pending").length;
        const cancelCount = checks.filter((c: any) => c.bucket === "cancel").length;

        return ok(lines.join("\n"), {
          owner: ref.owner, repo: ref.repo, number: ref.number, count: checks.length,
          passed: passCount, failed: failCount, skipped: skippedCount + cancelCount, pending: pendingCount,
        });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      const label = args.url || `${args.owner}/${args.repo}#${args.number}`;
      return new Text(theme.fg("toolTitle", theme.bold("GitHub — View PR Checks ")) + theme.fg("muted", String(label)), 0, 0);
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error || d?.count == null) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      if (d.count === 0) return new Text(theme.fg("muted", "○ no checks"), 0, 0);
      const summary = [
        d.passed > 0 ? theme.fg("success", `${d.passed}✓`) : null,
        d.failed > 0 ? theme.fg("error", `${d.failed}✗`) : null,
        d.pending > 0 ? theme.fg("dim", `${d.pending}◐`) : null,
        d.skipped > 0 ? theme.fg("muted", `${d.skipped}⊘`) : null,
      ].filter(Boolean).join(" ");
      return new Text(theme.fg("success", "✓ ") + `${d.count} checks — ${summary}`, 0, 0);
    },
  });

  // ─── gh_pr_job_logs ───────────────────────────────────────────────────────

  pi.registerTool({
    name: "gh_pr_job_logs",
    label: "GitHub — View PR Job Logs",
    description:
      "Get CI job logs for a pull request. Shows output from failed or specific jobs. " +
      "Only works for GitHub Actions — for Buildkite CI, use bk_failed_jobs and bk_job_logs instead. " +
      "Provide a URL or (owner + repo + number). Optional job name filter (e.g. 'typecheck', 'test').",
    parameters: Type.Object({
      url: Type.Optional(Type.String({ description: "GitHub PR URL" })),
      owner: Type.Optional(Type.String({ description: "Repository owner" })),
      repo: Type.Optional(Type.String({ description: "Repository name" })),
      number: Type.Optional(Type.Number({ description: "PR number" })),
      job: Type.Optional(Type.String({ description: "Specific job name to filter (e.g. 'typecheck', 'test')" })),
      lines: Type.Optional(Type.Number({ description: "Number of log lines to return (default: 100, max: 500)" })),
    }),
    async execute(_id, params, signal) {
      try {
        const ref = resolveRef(params);
        const jobFilter = params.job?.toLowerCase() ?? "";
        const lineCount = Math.min(params.lines ?? 100, 500);

        const prFields = "number,headRefName,title";
        const prRaw = await gh(
          ["pr", "view", String(ref.number), "--repo", `${ref.owner}/${ref.repo}`, "--json", prFields],
          signal,
        );
        const pr = JSON.parse(prRaw);

        const checksRaw = await gh(
          [
            "api", "--paginate",
            `/repos/${ref.owner}/${ref.repo}/commits/${pr.headRefName}/check-runs`,
            "--jq", ".check_runs[] | .app.slug",
          ],
          signal,
        ).catch(() => "");
        const checkApps = checksRaw.split("\n").filter(Boolean);
        const hasBuildkite = checkApps.some((app: string) => app.includes("buildkite"));
        const hasGHActions = checkApps.some((app: string) => app === "github-actions");

        if (hasBuildkite && !hasGHActions) {
          return ok(
            `PR #${ref.number} uses Buildkite for CI, not GitHub Actions.\n` +
            `Use these tools instead:\n` +
            `  1. gh_pr_checks — to find the Buildkite build URL\n` +
            `  2. bk_failed_jobs — with the build URL to list failed jobs\n` +
            `  3. bk_job_logs or bk_job_failure — to get the actual log output`,
            { owner: ref.owner, repo: ref.repo, number: ref.number, count: 0, ci: "buildkite" },
          );
        }

        const runsRaw = await gh(
          [
            "run", "list",
            "--repo", `${ref.owner}/${ref.repo}`,
            "--branch", pr.headRefName,
            "--limit", "1",
            "--json", "databaseId,status,conclusion",
          ],
          signal,
        );
        const runs = JSON.parse(runsRaw);
        if (!runs.length) {
          const hint = hasBuildkite
            ? "\nThis repo uses Buildkite — use bk_failed_jobs with the build URL from gh_pr_checks."
            : "";
          return ok(
            `No GitHub Actions workflow runs found for PR #${ref.number}.${hint}`,
            { owner: ref.owner, repo: ref.repo, number: ref.number, count: 0 },
          );
        }

        const runId = runs[0].databaseId;

        const jobsRaw = await gh(
          [
            "run", "view", String(runId),
            "--repo", `${ref.owner}/${ref.repo}`,
            "--json", "jobs",
          ],
          signal,
        );
        const runData = JSON.parse(jobsRaw);
        const jobs = runData.jobs ?? [];

        let filteredJobs = jobs;
        if (jobFilter) {
          filteredJobs = jobs.filter((j: any) => j.name.toLowerCase().includes(jobFilter));
        } else {
          filteredJobs = jobs.filter((j: any) => j.conclusion && j.conclusion !== "success");
        }

        if (!filteredJobs.length) {
          const msg = jobFilter
            ? `No jobs matching "${jobFilter}" found.`
            : "No failed jobs found.";
          return ok(msg, { owner: ref.owner, repo: ref.repo, number: ref.number, count: 0 });
        }

        const lines: string[] = [
          `# Job Logs for PR #${ref.number} — ${pr.title}`,
          `Branch: ${pr.headRefName}`,
          "",
        ];

        for (const job of filteredJobs) {
          const jobName = job.name || "unknown";
          const conclusion = job.conclusion || job.status || "pending";
          const icon = conclusion === "success" ? "✓" : conclusion === "failure" ? "✗" : "◐";

          lines.push(`${icon} **${jobName}** — ${conclusion}`);

          if (job.databaseId) {
            try {
              const result = await pi.exec(
                "gh",
                ["run", "view", String(runId), "--repo", `${ref.owner}/${ref.repo}`, "--log-failed"],
                { signal, timeout: 30000 },
              );
              const logsRaw = result.stdout || result.stderr;

              if (logsRaw.trim()) {
                const logLines = logsRaw.split("\n");
                const relevantLines = logLines.filter((line: string) => {
                  const lower = line.toLowerCase();
                  return lower.includes(jobName.toLowerCase()) ||
                    lower.includes("error") || lower.includes("fail") ||
                    lower.includes("assert") || lower.includes("exception");
                });

                const outputLines = relevantLines.length > 0
                  ? relevantLines.slice(-lineCount)
                  : logLines.slice(-lineCount);

                for (const line of outputLines) {
                  lines.push(`  ${line}`);
                }
              } else {
                lines.push("  (no log output)");
              }
            } catch (_logErr) {
              try {
                const fallback = await pi.exec(
                  "gh",
                  ["run", "view", String(runId), "--repo", `${ref.owner}/${ref.repo}`, "--log"],
                  { signal, timeout: 30000 },
                );
                const logLines = (fallback.stdout || "").split("\n");

                const jobLines = logLines.filter((line: string) =>
                  line.toLowerCase().includes(jobName.toLowerCase()),
                );
                const outputLines = (jobLines.length > 0 ? jobLines : logLines).slice(-lineCount);
                for (const line of outputLines) {
                  lines.push(`  ${line}`);
                }
              } catch (_fallbackErr) {
                lines.push("  (could not fetch logs)");
              }
            }
          }

          lines.push("");
        }

        return ok(lines.join("\n"), {
          owner: ref.owner, repo: ref.repo, number: ref.number,
          count: filteredJobs.length, jobNames: filteredJobs.map((j: any) => j.name),
        });
      } catch (err) {
        return errorResult(err);
      }
    },
    renderCall(args, theme) {
      const label = args.url || `${args.owner}/${args.repo}#${args.number}`;
      const jobPart = args.job ? theme.fg("dim", ` (${args.job})`) : "";
      return new Text(
        theme.fg("toolTitle", theme.bold("GitHub — View PR Job Logs ")) +
        theme.fg("muted", String(label)) +
        jobPart,
        0, 0,
      );
    },
    renderResult(result, _opts, theme) {
      const d = result.details as any;
      if (d?.error || d?.count == null) return new Text(theme.fg("error", "✗ failed"), 0, 0);
      if (d.ci === "buildkite") return new Text(theme.fg("warning", "⚠ ") + "Buildkite CI — use bk_* tools", 0, 0);
      if (d.count === 0) return new Text(theme.fg("muted", "○ no jobs"), 0, 0);
      const jobs = (d.jobNames ?? []).join(", ");
      return new Text(theme.fg("success", "✓ ") + `${d.count} job(s): ${jobs}`, 0, 0);
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
    const full = params.url.match(/github\.com\/([^/]+)\/([^/]+)\/(issues|pull)\/(\d+)/);
    if (full) return { owner: full[1], repo: full[2], number: parseInt(full[4], 10) };

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
