---
name: git
description: Git operations for branch creation, commits, rebases, pushes, and PR preparation. Default workflow for shop/world GitStream repos; use graphite skill only for intentional stacks.
---

# Git Operations

Use plain `git` as the default workflow for `shop/world` and other GitStream Full Mode repos.
Use the `graphite` skill only when intentionally managing a stacked PR workflow until `gs` is available.

## Core Rules

- **Never use `git add .` or `git add -A`** — stage specific files or subdirectories.
- In plan mode, do not mutate branches, commits, remotes, or PRs.
- In `shop/world`, prefer `git fetch origin` and targeted fetches over broad recovery commands.
- Avoid generic `git pull` in sparse World checkouts unless the user explicitly asks for it.
- For stale GitHub, PR, or CI state after a push, check GitStream mirror state before guessing.

## Branches

```bash
git switch -c <branch>      # Create and switch to a new branch
git checkout -b <branch>    # Equivalent fallback
git switch <branch>         # Switch to an existing branch
git status                  # Inspect working tree
git branch                  # List branches
```

## Staging & Committing

```bash
git add <file>              # Stage a specific file
git add <dir>/              # Stage a specific subdirectory
git add -p                  # Interactive hunk staging
git commit -m "message"     # Commit staged changes
git commit --amend          # Amend HEAD
```

## Non-Interactive Commit Amendment

To amend specific commits, create fixup commits and autosquash them:

```bash
git add <file>
git commit --fixup=<target-sha>
GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base-branch>
```

Use `gt modify --into <branch>` only when intentionally amending a different branch inside a Graphite-managed stack.

## Viewing History

```bash
git log --oneline -n 10                    # Recent commits
git log --oneline <parent>..HEAD           # Commits on current branch only
git diff <parent> -- <file>                # Changes to file on this branch
git show HEAD                              # Inspect commit
```

## Fetching & Pushing in GitStream Repos

```bash
git fetch origin
git push
```

If a pushed branch is not visible in GitHub, CI, or the PR:

```bash
dev gitstream push-status <branch>
```

Interpret GitStream status before retrying pushes or using stack tools. Avoid `gt get`, `gt sync`, and repeated restacks while local, GitStream, and GitHub SHAs may be misaligned.

## PRs and Merge Garden

For single `shop/world` PRs, use GitHub UI or `gh pr create` when explicitly asked.

Queue and cancel Merge Garden through PR comments:

```bash
gh pr comment <PR_NUMBER> --body "/merge"
gh pr comment <PR_NUMBER> --body "/cancel-merge"
```

Do not use Graphite merge buttons for Merge Garden queue actions.

## When to Use Graphite

Use the `graphite` skill only for intentional stacked PR workflows:

- inspecting a stack
- creating branches that are part of a stack
- moving/reordering/restacking a stack
- submitting a stack until `gs` replaces `gt`

For normal branch, commit, push, and single-PR work in `shop/world`, stay on plain `git`.
