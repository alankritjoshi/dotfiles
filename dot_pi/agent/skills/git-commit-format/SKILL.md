---
name: git-commit-format
description: >
  Conventional Commits format for git commit messages. Use when
  committing code, writing commit messages, or discussing commit
  conventions.
---

# Git Commit Format

Use [Conventional Commits](https://www.conventionalcommits.org/).

## Format

```
<type>(<scope>): <subject>

<body>
```

## Subject Line

- **Type:** feat, fix, refactor, docs, test, chore, ci, perf, style, build
- **Scope:** optional, describes what area (e.g., `plan-mode`, `guardian`, `memory`)
- **Subject:** imperative mood, lowercase, no period, max 72 chars
- Examples: `feat(tdd): add phase enforcement`, `fix: handle empty commit message`

## Body

- Optional — use for non-trivial changes
- Wrap at 72 characters
- Explain *what* and *why*, not *how*
- Separate from subject with a blank line

## Breaking Changes

- Add `!` after type/scope: `feat(api)!: remove deprecated endpoint`
- Or add `BREAKING CHANGE:` footer in the body

## Commit Granularity

- One logical change per commit
- Tests and implementation together (they're one unit of work)
- Don't mix refactoring with feature changes
- Don't mix formatting with logic changes
