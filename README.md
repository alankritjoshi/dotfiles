# Alankrit's Dotfiles (macOS)

A declarative macOS configuration using **nix-darwin**, **home-manager**, and **chezmoi**.

## Prerequisites

```bash
# Install Xcode Command Line Tools
xcode-select --install
```

## Quick Setup

One-liner installation:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply alankritjoshi
```

This will:
1. Install chezmoi
2. Clone and apply dotfiles
3. Install Nix
4. Setup nix-darwin with home-manager
5. Install all packages and configure the system

## Post-Installation

After installation, you can:

### Apply configuration changes (recommended)
```bash
chezmoi apply
```
This runs scripts that handle nix-darwin rebuilds with automatic conflict resolution.

### Update dotfiles from remote
```bash
chezmoi update  # Pulls changes and applies them
```

### Manual nix-darwin operations (if needed)
```bash
# Update package versions
nix flake update ~/.config/nix-darwin

# Rebuild manually (chezmoi apply handles this automatically)
sudo darwin-rebuild switch --flake ~/.config/nix-darwin
```

## Configuration Structure

```
~/.config/
├── nix-darwin/          # System configuration
│   ├── flake.nix        # Main flake configuration
│   ├── configuration.nix # System-level settings
│   ├── home.nix         # User-level packages and settings
│   └── modules/         # Modular configuration
│       ├── system.nix   # macOS system settings
│       ├── homebrew.nix # Homebrew casks and taps
│       └── packages.nix # System packages
├── fish/                # Fish shell config (managed by chezmoi)
├── nvim/                # Neovim config (managed by chezmoi)
└── ...                  # Other app configs

~/.local/share/chezmoi/  # Chezmoi source directory
├── .chezmoiscripts/     # Bootstrap scripts
├── dot_gitconfig.tmpl   # Git config template
└── ...                  # Other dotfile templates
```

## Package Management Strategy

- **Nix packages** (via nixpkgs): Development tools, CLI utilities, languages
- **Homebrew casks**: GUI applications not available in nixpkgs
- **Homebrew formulae**: Only for packages that don't work well with Nix on macOS

## Customization

### Adding packages

Edit `~/.config/nix-darwin/home.nix` for user packages or `~/.config/nix-darwin/modules/packages.nix` for system packages:

```nix
home.packages = with pkgs; [
  your-package-here
];
```

Then apply changes:
```bash
chezmoi apply  # Handles rebuild automatically
```

### Adding Homebrew casks

Edit `~/.config/nix-darwin/modules/homebrew.nix`:

```nix
casks = [
  "your-app-here"
];
```

Then apply:
```bash
chezmoi apply
```

### Modifying dotfiles

```bash
# Edit files directly (or use chezmoi edit)
vim ~/.config/fish/config.fish

# Update chezmoi's source with your changes
chezmoi re-add  # Auto-detects and updates changed files

# Push to remote
chezmoi git add .
chezmoi git commit -m "Update fish config"
chezmoi git push
```

## Troubleshooting

Note: `chezmoi apply` handles most conflicts automatically. These are manual fixes if needed.

### darwin-rebuild requires sudo
Recent nix-darwin versions require root privileges:
```bash
sudo darwin-rebuild switch --flake ~/.config/nix-darwin
```

### /etc file conflicts
If you see "Unexpected files in /etc":
```bash
# Move conflicting files (example for nix.conf)
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
```

### Home-manager file conflicts
If home-manager can't overwrite files:
```bash
# Remove conflicting symlinks
rm ~/.config/fish/config.fish ~/.config/gh/config.yml
# Or add backup extension in flake.nix:
# home-manager.backupFileExtension = "backup";
```

### Nix store corruption
If builds fail with "No such file or directory":
```bash
sudo nix-store --verify --check-contents --repair
```

### Rollback to previous configuration
```bash
sudo darwin-rebuild rollback
```

## License

MIT
