# Claude Assistant Guide

## Critical Rules
- **ALWAYS use `chezmoi apply`** - NEVER run `darwin-rebuild` directly
- Git config is managed by nix-darwin, NOT chezmoi
- Don't create files unless absolutely necessary
- Don't add documentation unless explicitly requested

## User Preferences
- Be concise and direct (no fluff)
- Fish shell, not Zsh or Bash
- Nix philosophy over convenience hacks
- Proper separation between work and personal
- Don't add packages like atuin (was rejected)
- Don't modify scripts without being asked

## Machine Hostnames
- `vanik` - work MacBook (Shopify)
- `tejas` - personal MacBook (future)
- `griha` - Mac Mini (future)

## What NOT to Do
- ❌ Run darwin-rebuild directly
- ❌ Manage gitconfig with chezmoi
- ❌ Modify scripts without being asked
- ❌ Add unnecessary packages
- ❌ Create documentation proactively
- ❌ Use verbose/fluffy responses
- ❌ Use emojis unless requested