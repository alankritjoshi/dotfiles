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
cd ~/.config/nix-darwin && nix flake update
chezmoi apply
```

## Development Shells

Isolated environments without global installation:

```bash
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
│   ├── nix-darwin/              # System configuration
│   │   ├── flake.nix           # Main flake
│   │   ├── devshell.nix        # Dev shells
│   │   ├── modules/            # Modular configs
│   │   ├── home-work.nix       # Work config
│   │   └── home-personal.nix   # Personal config
│   ├── private_fish/            # Fish shell
│   ├── private_aerospace/       # Window manager
│   └── private_ghostty/         # Terminal
├── .chezmoiscripts/             # Bootstrap scripts
├── .chezmoiencrypted/           # Encrypted SSH keys
├── CLAUDE.md                    # AI assistant guide
└── ROADMAP.md                   # Future plans
```

## Configuration

### Machines
- **Work laptop** (`Alankrits-MacBook-Pro`): Shopify config with SSH signing
- **Personal** (Mac Mini/Pro): Personal email and tools

### Package Strategy
- **Nix packages**: CLI tools, development utilities
- **Homebrew casks**: GUI applications (via nix-darwin)
- **Chezmoi**: Dotfiles and encrypted secrets

### Adding Packages

Edit the appropriate file:
- Universal → `~/.config/nix-darwin/modules/home-common.nix`
- Work only → `~/.config/nix-darwin/home-work.nix`
- Personal only → `~/.config/nix-darwin/home-personal.nix`

Then apply:
```bash
chezmoi apply
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
# Test decryption
chezmoi age decrypt --passphrase ~/.local/share/chezmoi/.chezmoiencrypted/encrypted_private_id_ed25519.age | head -n 1

# Re-encrypt from 1Password
op item get "pp4al2x5g4tkfg6etruniky3we" --account my.1password.com --fields "private key" --reveal | \
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
darwin-rebuild build --flake ~/.config/nix-darwin#$(hostname -s) --show-trace
```

### Rollback
```bash
sudo darwin-rebuild rollback
```

## Important Notes

- **Always use `chezmoi apply`** - never run `darwin-rebuild` directly
- Git config is in nix-darwin, not chezmoi
- Fish config is in chezmoi, not nix
- The chezmoi script handles `/etc/nix/nix.conf` conflicts automatically

## License

MIT