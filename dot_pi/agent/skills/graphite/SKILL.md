---
name: graphite
description: Manage intentional stacked PR workflows with Graphite CLI (gt). Transitional for shop/world until gs exists; not the default for GitStream single-PR work.
---

# Graphite Stack Management

Use `gt` only when intentionally managing a stacked PR workflow. In `shop/world`, plain `git` is the default for branch creation, commits/amends, rebases, pushes, and single-PR workflows. `gt` remains acceptable for stacks until Shopify's `gs` replacement is available.

## Before Using gt

- Confirm the user is working on a stack, not a normal single PR.
- In `shop/world`, avoid `gt get`, `gt sync`, and repeated restacks while debugging GitStream visibility or push failures.
- If GitHub, CI, or PR state looks stale after a push, check mirror state first:

```bash
dev gitstream push-status <branch>
```

- Do not mix raw `git rebase` and `gt` stack operations on the same stack unless intentionally chosen.
- Do not run `gt submit` unless explicitly asked.

## Read Stack State

```bash
gt ls --stack            # Show current stack
gt ls                    # Visual tree of branches
gt log short             # Compact stack view
gt log long              # Detailed stack view
gt trunk                 # Show stack base
```

## Navigate a Stack

These commands switch branches. Do not run them in plan mode.

```bash
gt top                   # Go to tip of stack
gt bottom                # Go to base branch
gt up [n]                # Move up n branches
gt down [n]              # Move down n branches
gt checkout <branch>     # Switch to a branch
```

## Create or Amend Stack Branches

Use only for branches that are intentionally part of a stack.

```bash
gt create <name> -a -m "message"  # New stack branch, stage all tracked changes, commit
gt modify -a -m "message"         # Amend current stack branch
gt modify --into <branch>         # Amend into a downstack branch
```

Still stage files deliberately when possible. Avoid `git add .` and `git add -A`.

## Submit a Stack

```bash
gt submit --no-edit      # Push + create/update PRs
gt submit --stack        # Submit entire stack
```

For single `shop/world` PRs, prefer the plain `git` workflow and GitHub UI or `gh pr create` instead.

## Sync & Restack

```bash
gt restack               # Rebase stack branches onto their parents
gt continue              # Continue after resolving conflicts
gt abort                 # Abort the active gt operation
gt sync                  # Clean up merged stack branches and update stack metadata
```

Use these only for stack maintenance. Do not use them as generic GitStream recovery commands.

## Conflict Resolution

```bash
gt restack
# If conflicts:
git status
# Resolve conflicted files
git add <resolved-files>
gt continue
```

When resolving conflicts, preserve both sides' intent. If local, GitStream, and GitHub SHAs may be misaligned, stop and inspect before continuing.

## Stack Reordering

```bash
gt move --source <branch> --onto <target>
gt reorder               # Interactive; avoid in agent context unless user explicitly requests it
```

## Branch Cleanup

```bash
gt delete <branch>
gt fold
gt squash
```

These mutate stack topology. Use only with explicit user intent.
