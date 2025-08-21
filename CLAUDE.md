# Claude Assistant Guide

## Critical Rules
- **ALWAYS edit files in `~/.local/share/chezmoi/`** - NEVER edit applied files in `~/.config/`
- **ALWAYS use `chezmoi apply`** - NEVER run `darwin-rebuild` directly
- Git config is managed by nix-darwin, NOT chezmoi
- Don't create files unless absolutely necessary
- Don't add documentation unless explicitly requested

## File Editing Rules
- When modifying configs, ALWAYS edit in `~/.local/share/chezmoi/`
- For nix configs: edit `~/.local/share/chezmoi/private_dot_config/nix/`
- For other dotfiles: edit corresponding files in `~/.local/share/chezmoi/`
- After editing, run `chezmoi apply` to apply changes

## User Preferences
- Be concise and direct (no fluff)
- Fish shell, not Zsh or Bash
- Nix philosophy over convenience hacks
- Proper separation between work and personal
- Don't add packages like atuin (was rejected)
- Don't modify scripts without being asked

## Code Style Preferences
- Use early exit/return patterns to avoid nested conditionals
- Assert preconditions early with assert statements
- Prefer flat code over deep nesting
- Return early when conditions aren't met
- Use assertions to fail fast instead of defensive if/else

## Machine Hostnames
- `vanik` - work MacBook (Shopify)
- `tejas` - personal MacBook
- `griha` - Mac Mini
- `agrani` - Linux desktop (Arch + Hyprland)

## What NOT to Do
- ❌ Run darwin-rebuild directly
- ❌ Manage gitconfig with chezmoi
- ❌ Modify scripts without being asked
- ❌ Add unnecessary packages
- ❌ Create documentation proactively
- ❌ Use verbose/fluffy responses
- ❌ Use emojis unless requested