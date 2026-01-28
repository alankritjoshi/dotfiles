# Shopify Development

## Available Skills

Load these with `/skill <name>` for detailed guidance:

- **graphite** - Stacked branches, PRs, stack management (`gt` CLI)
- **git** - Commits, staging, amendments (use graphite for branches)
- **shopify-ruby** - Slices, dev CLI, Sorbet/Tapioca, rubocop
- **infra-central** - Gordon job management (project-specific)
- **lineage-developer** - Lineage sync workflows (project-specific)

## Quick Reference

### Dev CLI

- Location: `/opt/dev/bin/dev`
- Prefer `dev` commands over direct tools
- Check `dev.yml` for project-specific commands

### Git Worktrees

Current directory may be a git worktree. Treat it as repo root.

### Project Setup

Run `/init` on new Shopify projects without `AGENTS.md`.

### Ignore File Setup

On Shopify projects, if no `.ignore` file exists in project root, create one to expose config files to the LLM:

```bash
cat ~/.config/opencode/.ignore.base ~/.config/opencode/.ignore.shopify > .ignore
```

This includes `.shopify-build/`, `dev.yml`, `slices.yml`, etc. in LLM context despite being gitignored.
