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
- Personal source: `~/.local/share/chezmoi/`
- Shopify source: `~/.local/share/chezmoi-shopify/`

## Commands

```fish
cz           # chezmoi (personal)
czs          # chezmoi --config ~/.config/chezmoi-shopify.yaml (shopify)
cza          # apply both instances
czu          # update both instances
```

## File Separation

### Personal chezmoi manages
- Fish config, functions, conf.d (non-Shopify)
- Nix config (all machines including vanik)
- Pi agent: personal skills, extensions, AGENTS.md, settings.json, keybindings, themes
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

## Mixed Files

Files with both personal and Shopify content stay in the **personal** repo as templates:
- `AGENTS.md.tmpl` — Shopify Development section guarded by `{{ if eq .machine "vanik" }}`
- `settings.json.tmpl` — shop-pi-fy package guarded similarly

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
# Edit in source dir
vim ~/.local/share/chezmoi/path/to/file
# Or use chezmoi add
chezmoi add ~/.config/something
```

Shopify file:
```bash
vim ~/.local/share/chezmoi-shopify/path/to/file
# Or
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
