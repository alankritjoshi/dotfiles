# Alankrit's Dotfiles (macOS)

A declarative macOS configuration using **nix-darwin**, **home-manager**, and **chezmoi**.

## Features

- 🚀 **Declarative system configuration** with nix-darwin
- 🏠 **User environment management** with home-manager  
- 📝 **Dotfile templating** with chezmoi
- 🔄 **Atomic updates and rollbacks** via Nix
- 🎯 **Minimal Homebrew usage** (only for GUI apps not in nixpkgs)

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

## Manual Setup

If you prefer to run steps individually:

```bash
# 1. Install chezmoi and clone dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)"
./bin/chezmoi init alankritjoshi

# 2. Apply dotfiles and run bootstrap
./bin/chezmoi apply

# 3. The bootstrap scripts will automatically:
#    - Install Nix
#    - Setup nix-darwin and home-manager
#    - Install all packages
#    - Configure system settings
```

## Post-Installation

After installation, you can:

### Update packages and configuration
```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
```

### Update Nix flake inputs (package versions)
```bash
nix flake update ~/.config/nix-darwin
darwin-rebuild switch --flake ~/.config/nix-darwin
```

### Update dotfiles
```bash
chezmoi update
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

Then rebuild:
```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
```

### Adding Homebrew casks

Edit `~/.config/nix-darwin/modules/homebrew.nix`:

```nix
casks = [
  "your-app-here"
];
```

### Modifying dotfiles

```bash
# Edit the actual file
chezmoi edit ~/.config/fish/config.fish

# Apply changes
chezmoi apply

# Commit changes
chezmoi cd
git add .
git commit -m "Update fish config"
git push
```

## Troubleshooting

### Nix command not found
```bash
# Source Nix profile
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### Permission issues with nix-darwin
```bash
# Ensure your user is in the nixbld group
sudo dscl . -append /Groups/nixbld GroupMembership $USER
```

### Rollback to previous configuration
```bash
darwin-rebuild rollback
```

## License

MIT