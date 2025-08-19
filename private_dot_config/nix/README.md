# Multi-Platform Nix Configuration

## 🏗️ Architecture

This configuration supports both macOS (Darwin) and Linux (NixOS/Arch) systems with a unified structure.

### Directory Structure

```
nix/
├── flake.nix                 # Main flake configuration
├── devshell.nix             # Development shells
├── modules/
│   ├── common/              # Shared across all platforms
│   │   ├── options.nix      # Configuration options
│   │   └── packages.nix     # Universal packages
│   ├── darwin/              # macOS-specific
│   │   ├── system.nix       # Darwin system config
│   │   ├── packages.nix     # macOS packages
│   │   └── homebrew.nix     # Homebrew casks/apps
│   ├── linux/               # Linux-specific
│   │   ├── system.nix       # Linux system config
│   │   ├── packages.nix     # Linux packages
│   │   └── hyprland.nix     # Hyprland WM config
│   └── home/                # Home-manager modules
│       ├── common.nix       # Common home config
│       ├── work.nix         # Work-specific
│       ├── personal.nix     # Personal-specific
│       ├── hyprland.nix     # Hyprland home config
│       ├── waybar.nix       # Waybar status bar
│       └── rofi.nix         # Rofi launcher
└── machines/                # Per-machine configurations
    ├── Alankrits-MacBook-Pro/  # Work laptop
    ├── mac-mini/               # Personal Mac Mini
    ├── mac-pro/                # Personal Mac Pro
    └── arch-desktop/           # Linux desktop
```

## 🖥️ Supported Systems

### macOS (Darwin)
- **Work**: Alankrits-MacBook-Pro (Shopify)
- **Personal**: mac-mini, mac-pro

### Linux (Future)
- **Personal**: arch-desktop (Arch Linux + Hyprland)

## 🚀 Usage

### Building Configurations

```bash
# macOS - use chezmoi (recommended)
chezmoi apply

# Or direct flake commands:
# Work laptop
darwin-rebuild switch --flake .#Alankrits-MacBook-Pro

# Personal Mac
darwin-rebuild switch --flake .#mac-mini

# Linux (future)
sudo nixos-rebuild switch --flake .#arch-desktop
```

### Development Shells

```bash
nix develop          # Default shell
nix develop .#go     # Go development
nix develop .#python # Python development
nix develop .#rust   # Rust development
```

## 🎯 Key Features

### Cross-Platform
- Unified configuration for macOS and Linux
- Shared packages and settings where possible
- Platform-specific optimizations

### macOS Features
- Aerospace window manager
- Homebrew integration for GUI apps
- Mac App Store apps via mas

### Linux Features (Configured, Ready for Hardware)
- Hyprland tiling compositor
- Waybar status bar
- Rofi application launcher
- Full Wayland support
- Gaming support (Steam, Lutris)
- Catppuccin theming throughout

### Smart Configuration
- Machine type detection (work vs personal)
- Conditional package installation
- Environment-specific settings

## 📦 Package Management

### Priority Order
1. **nixpkgs** - Preferred for all packages
2. **Homebrew casks** - macOS GUI apps not in nixpkgs
3. **Mac App Store** - Apps only available there

### Notable Packages

**Universal** (all platforms):
- Neovim, Fish, Starship
- Modern CLI tools (eza, bat, ripgrep, etc.)
- Development tools (Go, Python/uv, Node.js)

**macOS-specific**:
- Wezterm, Aerospace, Raycast
- 1Password, Stats, BetterDisplay

**Linux-specific**:
- Alacritty, Hyprland, Waybar
- OBS Studio, Discord, Spotify

## 🔧 Configuration Options

Options are defined in `modules/common/options.nix`:

- `machineType`: work-laptop, personal-desktop, personal-laptop
- `isWork`/`isPersonal`: Derived from machine type
- `isDarwin`/`isLinux`: Platform detection
- `enableHyprland`: Enable Hyprland WM (Linux)
- `enableGaming`: Gaming packages (Linux)
- `enable3DPrinting`: 3D printing tools

## 🎨 Theming

- **Terminal**: Catppuccin themes
- **Linux Desktop**: Full Catppuccin theming
  - GTK, Qt, cursors, icons
  - Waybar, Rofi, Hyprland

## 🔐 Security

- SSH key signing for Git
- Age encryption for secrets
- 1Password integration
- Separate work/personal configurations