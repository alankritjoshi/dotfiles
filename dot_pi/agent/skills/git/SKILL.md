---
name: git
description: Git operations for commits, staging, and amendments. For branch management, use graphite skill and gt_* tools instead.
---

# Git Operations

For **branch management** (creating, reordering, pushing, PRs), use the `graphite` skill and `gt_*` tools.
Use git directly only for **commits, staging, and amendments**.

## Staging & Committing

**NEVER use `git add .` or `git add -A`** — always stage files or subdirectories individually to avoid committing untracked files (e.g. `.pi/`, editor configs).

```bash
git add <file>           # Stage specific file
git add <dir>/           # Stage specific subdirectory
git add -p               # Interactive staging (hunks)
git commit -m "message"  # Commit with message
git commit --amend       # Amend last commit
```

## Non-Interactive Commit Amendment

To amend specific commits (not just HEAD) without interactive rebase:

### Step 1: Create fixup commits

```bash
git add <file>
git commit --fixup=<target-sha>
```

### Step 2: Autosquash rebase (non-interactive)

```bash
GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base-branch>
```

This squashes fixup commits into their targets without opening an editor.

### When to use this vs graphite

- **Use `gt modify --into <branch>`** when amending a different branch in your stack
- **Use fixup + autosquash** when amending specific commits within the same branch

## Viewing History

```bash
git log --oneline -n 10                    # Recent commits
git log --oneline <parent>..HEAD           # Commits on current branch only
git diff <parent> -- <file>                # Changes to file on this branch
```

## Stashing

```bash
git stash                    # Stash changes
git stash pop                # Restore stashed changes
git stash list               # List stashes
```

## Important Notes

- **Never use `-i` flag** for interactive commands (not supported in agent context)
- **Pushing/submitting**: Use `gt_submit` tool (or `gt submit` via bash), never `git push`
- **Branch operations**: Use `gt_*` tools (`gt_create`, `gt_checkout`, `gt_modify`, etc.)
- **Stack visualization**: Use `gt_stack` or `gt_ls` tools instead of `git log`
