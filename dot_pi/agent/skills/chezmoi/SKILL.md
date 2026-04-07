---
name: chezmoi
description: Chezmoi dotfile management — two instances (personal + shopify), naming conventions, templates, and non-interactive usage
---

# Chezmoi Dotfile Management

## Setup

Two chezmoi instances manage dotfiles:

- **Personal** (public): `~/.local/share/chezmoi/` → `alankritjoshi/dotfiles`
- **Shopify** (private): `~/.local/share/chezmoi-shopify/` → `alankritjoshi/dotfiles-shopify`

Config files:
- Personal: `~/.config/chezmoi/chezmoi.yaml`
- Shopify: `~/.config/chezmoi-shopify.yaml`

## Rules

- **ALWAYS edit files in the chezmoi source dir** — never edit applied files directly
- **NEVER run `chezmoi apply`** — user applies manually
- **NEVER run `darwin-rebuild`** — user runs manually
- When running `chezmoi diff`, use `--no-pager` to avoid interactive mode
- Personal source: `~/.local/share/chezmoi/`
- Shopify source: `~/.local/share/chezmoi-shopify/`
- **Disk is always truth** — when source and disk disagree, `chezmoi add` the disk version. NEVER assume source is ahead unless you just edited it.
- `chezmoi add` auto-commits and auto-pushes (autoCommit + autoPush enabled)
- Templates (`.tmpl`) can't use `chezmoi add` — edit the source file manually
- Shopify chezmoi can only manage files under `~/.pi/` — `~/.config/` is personal chezmoi's domain

## Commands

```fish
cz           # chezmoi (personal)
czs          # chezmoi --config ~/.config/chezmoi-shopify.yaml (shopify)
cza          # apply both instances
czu          # update both instances
```

## Non-Interactive Usage

Always use `--no-pager` when running chezmoi commands that produce output:
```bash
chezmoi diff --no-pager          # personal
czs diff --no-pager              # shopify
chezmoi managed --no-pager       # list managed files
chezmoi cat ~/.pi/agent/AGENTS.md  # preview rendered template
```

When applying non-interactively (e.g. from pi):
```bash
chezmoi apply --force --exclude=scripts   # skip scripts that need sudo/tty
```

## Understanding `chezmoi diff`

The diff shows what `chezmoi apply` would change on disk:
- `-` lines = what's currently on disk (would be REMOVED)
- `+` lines = what's in chezmoi source (would be WRITTEN)

If disk is correct and source is stale → `chezmoi add <target-file>`
If source is correct and disk is outdated → `chezmoi apply` (or `cza`)

## File Separation

### Personal chezmoi manages
- Fish config, functions, conf.d (non-Shopify)
- Nix config (all machines including vanik)
- Pi agent: personal skills, extensions, AGENTS.md, settings.json, keybindings, themes
- Nvim plugin configs (even Shopify-specific like shadowenv — harmless on other machines)
- SSH keys, git config

### Shopify chezmoi manages
- Pi agent: Shopify-specific skills (dev, shopify-ruby, repositories/)
- Pi agent: Shopify-specific extensions (draw)
- Fish conf.d/shopify.fish (dev CLI sourcing, tec init)

### Not managed by chezmoi
- `~/.pi/agent/auth.json` — secrets
- `~/.pi/agent/git/` — pi package manager
- `~/.pi/agent/sessions/`, `investigations/`, `packages/` — transient
- Shop-pi-fy symlinks — managed by pi packages
- Nix per-tool modules (aerospace, bat, fish, git, etc.) — TODO: add to chezmoi

## Mixed Files

Files with both personal and Shopify content stay in the **personal** repo as templates:
- `AGENTS.md.tmpl` — Shopify Development section guarded by `{{ if eq .machine "vanik" }}`
- `settings.json.tmpl` — shop-pi-fy package + tool-gateway guarded similarly

**Never have both instances manage the same file** — this causes conflicts.

## Template Variable

Machine-specific conditionals use `{{ .machine }}` (set in chezmoi.yaml `data.machine`):
- `vanik` — work laptop (Shopify)
- `tejas` — personal MacBook
- `griha` — Mac Mini
- `agrani` — Linux desktop

## Chezmoi Naming Conventions

| Target path | Source name |
|---|---|
| `~/.config/X` | `private_dot_config/X` |
| `~/.pi/X` | `dot_pi/X` |
| `~/.ssh/X` | `dot_ssh/X` |
| Template | append `.tmpl` |
| Executable script | prefix `executable_` |
| Run after apply | prefix `run_after_` |

## Adding New Files

Personal file:
```bash
chezmoi add ~/.config/something       # auto-commits + auto-pushes
# Or edit source directly:
vim ~/.local/share/chezmoi/path/to/file
git add ... && git commit && git push  # manual commit needed
```

Shopify file:
```bash
chezmoi --config ~/.config/chezmoi-shopify.yaml add ~/.pi/agent/skills/new-skill/SKILL.md
```

## Bootstrap (New Machine)

```fish
# Personal (always)
chezmoi init alankritjoshi/dotfiles
chezmoi apply

# Shopify (after GitHub SSH works)
chezmoi init --config ~/.config/chezmoi-shopify.yaml \
    --source ~/.local/share/chezmoi-shopify alankritjoshi/dotfiles-shopify
chezmoi --config ~/.config/chezmoi-shopify.yaml apply
```
