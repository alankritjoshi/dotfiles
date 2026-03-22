---
name: graphite
description: Manage stacked branches and pull requests with Graphite CLI (gt) - reorder, restack, submit. Prefer gt_* tools over bash.
---

# Graphite CLI

Guide for using Graphite CLI (`gt`) to manage stacked branches and pull requests.

## Prefer gt_* Tools

Use the registered `gt_*` tools instead of running `gt` via bash when possible:

| Tool | Equivalent |
|------|-----------|
| `gt_stack` | `gt log short` |
| `gt_ls` | `gt ls` |
| `gt_branch_info` | `gt log long` |
| `gt_create` | `gt create <name> -a -m <msg>` |
| `gt_modify` | `gt modify -a [-m <msg>] [--into <branch>]` |
| `gt_checkout` | `gt checkout`, `gt top/bottom/up/down` |
| `gt_submit` | `gt submit --no-edit` |
| `gt_restack` | `gt restack` |
| `gt_sync` | `gt sync` |

Fall back to bash only for commands not covered by tools (e.g. `gt reorder`, `gt move`, `gt fold`).

## Core Concepts

Graphite manages **stacked branches** - a series of dependent branches where each branch builds on the previous one. This enables incremental code review and faster iteration.

```
feature-part-3  ← top of stack
    |
feature-part-2
    |
feature-part-1  ← bottom of stack
    |
  main          ← trunk
```

## Essential Commands

### Viewing Stack State

```bash
gt ls                    # Show current stack structure (visual tree)
gt log                   # Interactive stack explorer
gt log short             # Compact stack view
gt log long              # Detailed stack view with commit info
```

### Navigation

```bash
gt top                   # Go to tip of current stack
gt bottom                # Go to branch closest to trunk
gt up [n]                # Move up n branches (default: 1)
gt down [n]              # Move down n branches (default: 1)
gt checkout <branch>     # Switch to specific branch
gt trunk                 # Show trunk branch name
```

### Creating & Modifying Branches

```bash
gt create <name>         # Create new branch on top of current, commit staged changes
gt modify                # Amend current commit (auto-restacks descendants)
gt modify --commit       # Create new commit instead of amending
gt modify --all          # Stage all changes before committing
gt modify -m "message"   # Specify commit message directly
gt modify --into <branch>  # Amend changes into a specific downstack branch
```

### Stack Reordering

**Interactive reorder (opens editor):**

```bash
gt reorder               # Reorder all branches between trunk and current
```

**Non-interactive move (single branch):**

```bash
gt move --onto <target>                    # Move current branch onto target
gt move --source <branch> --onto <target>  # Move specific branch onto target
```

**Example - Move branch to new parent:**

```bash
# Move "feature-b" to be on top of "feature-a" instead of its current parent
gt move --source feature-b --onto feature-a
```

### Restacking

```bash
gt restack               # Rebase all branches to ensure proper parent relationships
gt restack --upstack     # Only restack current branch and descendants
gt restack --downstack   # Only restack current branch and ancestors
gt restack --only        # Only restack current branch
```

### Conflict Resolution

When conflicts occur during restack/reorder:

```bash
# 1. Resolve conflicts in files
# 2. Stage resolved files
gt add -A                # Stage all resolved files
# 3. Continue operation
gt continue              # Resume interrupted operation

# Or abort if needed
gt abort                 # Cancel current operation
```

### Branch Management

```bash
gt delete <branch>       # Delete branch, restack children onto parent
gt rename <new-name>     # Rename current branch
gt fold                  # Fold current branch into parent
gt split                 # Split current branch into multiple branches
gt squash                # Squash all commits in current branch into one
gt pop                   # Delete current branch, keep working tree changes
```

### Syncing & Submitting

```bash
gt sync                  # Sync all branches from remote, prompt to delete merged
gt submit                # Push branches and create/update PRs
gt submit --no-edit      # Submit without editing PR descriptions
gt get <branch>          # Fetch branch and its stack from remote
```

### Tracking

```bash
gt track                 # Start tracking current branch with Graphite
gt track <branch>        # Start tracking specific branch
gt untrack <branch>      # Stop tracking branch
```

## Common Workflows

### Reordering a Stack

**Scenario:** You have branches in wrong order and need to rearrange them.

**Method 1: Interactive (gt reorder)**

```bash
gt top                   # Go to top of stack
gt reorder               # Opens editor - arrange lines in desired order
# Save and close editor
gt restack               # May be needed to propagate changes
```

**Method 2: Non-interactive (gt move)**

```bash
# Move branches one at a time
gt move --source branch-to-move --onto new-parent
gt restack               # Propagate changes through stack
```

### Preserving Unstaged Changes During Reorder

When you have uncommitted changes that belong on a different branch:

```bash
# 1. Save changes
git diff > ~/my-changes.patch
git stash push -m "changes for target-branch"

# 2. Reorder stack
gt reorder               # Or use gt move

# 3. Apply changes to target branch
gt checkout target-branch
git stash pop            # Or: git apply ~/my-changes.patch

# 4. Commit and restack
git add -A
git commit -m "description"
gt restack
```

### Amending a Downstack Branch

When you need to add changes to a branch that's not at the top of stack:

```bash
# Stage your changes
git add <files>

# Amend into specific branch (must be downstack)
gt modify --into <target-branch>
```

Alternative approach:

```bash
gt checkout <target-branch>
git add <files>
gt modify                # Amends current branch
gt top                   # Return to top
gt restack               # Propagate changes
```

### Handling Restack Conflicts

```bash
gt restack
# If conflicts occur:

# 1. Check which files have conflicts
git status

# 2. Open conflicted files, resolve conflicts (remove <<<< ==== >>>> markers)

# 3. Stage resolved files
gt add -A

# 4. Continue
gt continue

# Repeat if more conflicts occur
```

## Flags Reference

### Global Flags

```
--cwd <dir>        Run in specified directory
--debug            Show debug output
--no-interactive   Disable prompts/editors
--no-verify        Skip git hooks
--quiet            Minimize output
```

### gt modify Flags

```
-c, --commit       Create new commit instead of amending
-a, --all          Stage all changes first
-m, --message      Specify commit message
-e, --edit         Open editor for commit message
--into <branch>    Target specific downstack branch
--reset-author     Update commit author to current user
```

### gt move Flags

```
-o, --onto <branch>    Target branch to move onto
-s, --source <branch>  Branch to move (default: current)
```

### gt restack Flags

```
-u, --upstack      Only restack upstack branches
-d, --downstack    Only restack downstack branches
-o, --only         Only restack current branch
```

### gt submit Flags

```
--no-edit          Don't open editor for PR descriptions
--draft            Create PRs as drafts
--stack            Submit entire stack
```

## Tips & Best Practices

1. **Run `gt ls` frequently** to visualize your stack state

2. **Use `gt modify --into`** when you realize changes belong on a different branch

3. **Prefer `gt move` over `gt reorder`** for simple single-branch moves (non-interactive)

4. **Always `gt restack` after manual git operations** to ensure Graphite metadata is in sync

5. **Stash or commit before reordering** to avoid losing work

6. **Check `gt log short` after operations** to verify expected state

7. **Use `gt undo`** if something goes wrong (undoes recent Graphite mutations)

8. **Do NOT run `gt submit`** - User prefers to submit PRs manually. Only push/submit if explicitly requested.

9. **NEVER use `git push` on Graphite-tracked branches** - Always use `gt submit` for pushing. Raw `git push` bypasses Graphite's metadata tracking and causes desync errors (e.g., remote/local mismatch, failed submits). This applies to creating PRs too — use `gt submit` which both pushes and creates/updates PRs, not `git push` + `gh pr create` separately.

10. **Always use `gt create` for new branches** - Use `gt_create` (not `git checkout -b`) for ALL new branches, even independent ones off main. This ensures Graphite tracks them from the start. `gt submit` then handles push + PR creation. Never use `git checkout -b` + `git push` + `gh pr create` — that's three commands doing what `gt create` + `gt submit` does in two, with proper tracking.

## Troubleshooting

### "Branch needs restack"

```bash
gt restack
```

### Stuck in conflict state

```bash
gt abort                 # Cancel current operation
git status               # Check state
git rebase --abort       # If git rebase is stuck
```

### Lost changes

```bash
git reflog               # Find lost commits
git stash list           # Check stash
```

### Graphite metadata out of sync

```bash
gt track                 # Re-track current branch
gt restack               # Rebuild relationships
```
