---
name: graphite
description: Manage stacked branches and pull requests with Graphite CLI (gt). Run gt commands via bash. MUST READ before any branch management in Graphite repos.
---

# Graphite CLI

Run `gt` commands via bash for stacked branch management.

## Essential Commands

```bash
# View stack
gt ls --stack            # Show current stack (preferred)
gt ls                    # Visual tree of all branches
gt log short             # Compact stack view
gt log long              # Detailed with commit info

# Navigate
gt top                   # Go to tip of stack
gt bottom                # Go to base branch
gt up [n]                # Move up n branches
gt down [n]              # Move down n branches
gt checkout <branch>     # Switch to specific branch

# Create & Modify
gt create <name> -a -m "message"  # New branch, stage all, commit
gt modify -a -m "message"         # Amend current branch
gt modify --into <branch>         # Amend into a downstack branch

# Push & PR
gt submit --no-edit      # Push + create/update PRs
gt submit --stack        # Submit entire stack

# Sync & Restack
gt sync                  # Sync from remote, prompt to delete merged
gt restack               # Rebase all branches to proper parents
```

## Critical Rules

1. **NEVER use `git push` on Graphite branches** — always `gt submit`
2. **NEVER use `git checkout -b`** — always `gt create`
3. **NEVER use `git commit`** — use `gt create` (new branch) or `gt modify` (amend)
4. Read-only git commands are fine: `git status`, `git diff`, `git log`, `git show`
5. Always stage files individually (`git add <file>`) — never `git add .` or `git add -A`
6. Do NOT run `gt submit` unless explicitly asked — user prefers to submit manually

## Conflict Resolution

```bash
gt restack
# If conflicts:
git status               # Check conflicted files
# ... resolve conflicts in files ...
git add <resolved-files>
gt continue              # Resume operation
# Or: gt abort           # Cancel
```

## Stack Reordering

```bash
gt reorder               # Interactive editor — rearrange branch order
gt move --source <branch> --onto <target>  # Move single branch
```

## Branch Cleanup

```bash
gt delete <branch>       # Delete branch, restack children onto parent
gt fold                  # Fold current branch into parent
gt squash                # Squash commits in current branch
```
