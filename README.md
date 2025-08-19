# Alankrit's Dotfiles

Declarative macOS configuration using **nix-darwin**, **home-manager**, and **chezmoi**.

## Quick Setup

```bash
# One-liner installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply alankritjoshi
```

This will:
1. Install chezmoi and clone dotfiles
2. Install Nix and setup nix-darwin
3. Configure the system and install packages
4. Decrypt SSH keys (prompts for passphrase)

## Daily Usage

```bash
# Apply configuration changes (ALWAYS use this)
chezmoi apply

# Update dotfiles from remote
chezmoi update

# Update packages
cd ~/.config/nix && nix flake update
chezmoi apply
```

### When changing nix configuration
```bash
# First apply config files without running scripts
chezmoi apply --exclude scripts

# Then run full apply to rebuild with new config
chezmoi apply
```

## Development Shells

Isolated environments without global installation:

```bash
cd ~/.config/nix
nix develop                    # Default shell
nix develop .#go              # Go development
nix develop .#python          # Python development  
nix develop .#rust            # Rust development
nix develop .#node            # Node.js development
nix develop .#full            # All languages + tools
```

## Architecture

```
~/.local/share/chezmoi/           # Dotfiles repo
├── private_dot_config/
│   ├── nix/                     # System configuration
│   │   ├── flake.nix           # Main flake
│   │   ├── devshell.nix        # Dev shells
│   │   ├── machines/           # Machine configs
│   │   └── modules/            # Modular configs
│   ├── fish/                    # Fish shell
│   ├── aerospace/               # Window manager
│   └── nvim/                    # Neovim config
├── .chezmoiscripts/             # Bootstrap scripts
├── .chezmoiencrypted/           # Encrypted SSH keys
├── CLAUDE.md                    # AI assistant guide
└── ROADMAP.md                   # Future plans
```

## Configuration

### Machines
- **Work laptop** (`vanik`): Shopify MacBook
- **Personal MacBook** (`tejas`): Personal development machine  
- **Mac Mini** (`griha`): Personal desktop/server
- **Linux Desktop** (`agrani`): Arch Linux with Hyprland (future)

### Package Strategy
- **Nix packages**: CLI tools, development utilities
- **Homebrew casks**: GUI applications (via nix-darwin)
- **Chezmoi**: Dotfiles and encrypted secrets

### Adding Packages

Edit the appropriate file:
- Universal → `~/.config/nix/modules/common/packages.nix`
- macOS GUI apps → `~/.config/nix/modules/darwin/homebrew.nix`
- macOS CLI tools → `~/.config/nix/modules/darwin/packages.nix`
- Linux packages → `~/.config/nix/modules/linux/packages.nix`
- Work-specific → `~/.config/nix/modules/home/work.nix`
- Personal-specific → `~/.config/nix/modules/home/personal.nix`

Then apply:
```bash
chezmoi apply --exclude scripts  # Update configs first
chezmoi apply                     # Then rebuild
```

### Managing Dotfiles

```bash
# Edit files directly
vim ~/.config/fish/config.fish

# Update chezmoi source
chezmoi re-add

# Push changes
chezmoi git add .
chezmoi git commit -m "Update config"
chezmoi git push
```

## SSH Key Management

Keys are encrypted with age using passphrase protection:

```bash
# Set 1Password item ID for SSH key
OP_SSH_KEY_ID="pp4al2x5g4tkfg6etruniky3we"

# Test decryption
chezmoi age decrypt --passphrase ~/.local/share/chezmoi/.chezmoiencrypted/encrypted_private_id_ed25519.age | head -n 1

# Re-encrypt from 1Password
op item get "$OP_SSH_KEY_ID" --account my.1password.com --fields "private key" --reveal | \
  chezmoi age encrypt --passphrase --output ~/.local/share/chezmoi/.chezmoiencrypted/encrypted_private_id_ed25519.age
```

## Troubleshooting

### Nix conflicts
```bash
# Move conflicting files
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
chezmoi apply
```

### Build failures
```bash
# Detailed error trace
darwin-rebuild build --flake ~/.config/nix#$(hostname -s) --show-trace
```

### Nix store corruption (missing .drv files)
If you get errors like `error: opening file '/nix/store/...-user-dbus-services.drv': No such file or directory`:

```bash
# 1. Find what references the missing derivations
sudo nix-store --query --referrers /nix/store/missing-file.drv

# 2. Delete the chain of problematic derivations
sudo nix-store --delete --ignore-liveness \
  /nix/store/problematic-derivation-1.drv \
  /nix/store/problematic-derivation-2.drv

# 3. Clean up the nix database
sudo sqlite3 /nix/var/nix/db/db.sqlite \
  "DELETE FROM ValidPaths WHERE path LIKE '%missing-derivation%';"

# 4. Clear caches and rebuild
rm -rf ~/.cache/nix/*
sudo rm -rf /tmp/nix-*
chezmoi apply
```

### Rollback
```bash
sudo darwin-rebuild rollback
```

## Important Notes

- **Always use `chezmoi apply`** - never run `darwin-rebuild` directly
- **When changing nix config**: Run `chezmoi apply --exclude scripts` first, then `chezmoi apply`
- **Unknown hostname**: Script will prompt to select configuration

## License

MIT
