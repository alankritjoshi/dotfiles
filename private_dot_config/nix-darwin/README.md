# Alankrit's Nix-Darwin Configuration

A modular nix-darwin configuration with home-manager for macOS, designed for both work (Shopify) and personal machines, with future support planned for Arch Linux with Hyprland.

## 🚀 Quick Start

### First Time Setup
```bash
# Clone and apply dotfiles
chezmoi init --apply alankritjoshi

# The setup script will automatically:
# 1. Install nix if not present
# 2. Setup nix-darwin
# 3. Apply the configuration
```

### Daily Commands
```bash
# Rebuild configuration (auto-detects machine)
nrs  # sudo darwin-rebuild switch

# Test build without applying
nrb  # darwin-rebuild build

# Update all packages
nfu  # nix flake update
nrs  # then rebuild

# Enter development shell
nix develop          # default shell
nix develop .#go     # Go development
nix develop .#python # Python development
nix develop .#rust   # Rust development
nix develop .#node   # Node.js development
nix develop .#full   # Everything
```

## 🏗️ Architecture

### Design Philosophy
- **Hybrid management**: Nix for packages/core config, chezmoi for dotfiles and secrets
- **Machine-specific configs**: Separate work and personal configurations
- **Options-based conditionals**: Using custom NixOS module options for clean configuration
- **Future-proof structure**: Preparing for multi-platform support (macOS + Linux)

### Directory Structure
```
~/.local/share/chezmoi/
├── private_dot_config/
│   └── nix-darwin/
│       ├── flake.nix              # Main flake with darwin configurations
│       ├── devshell.nix           # Development shells
│       ├── modules/
│       │   ├── options.nix        # Custom options (alankrit.isWork, etc.)
│       │   ├── common.nix         # Shared system configuration
│       │   └── home-common.nix    # Shared home-manager config
│       ├── home-work.nix          # Work laptop home config (Shopify)
│       └── home-personal.nix      # Personal machines home config
├── private_dot_config/
│   ├── private_fish/              # Fish shell config
│   ├── private_aerospace/         # Aerospace WM config
│   └── private_ghostty/           # Ghostty terminal config
└── ROADMAP.md                     # Future improvements plan
```

## 💻 Machines

### Work Laptop (Alankrits-MacBook-Pro)
- **Git**: Shopify email with GPG signing
- **Packages**: Development tools + Shopify-specific
- **Flake target**: `Alankrits-MacBook-Pro`

### Personal Machines (Mac Mini & Mac Pro)
- **Git**: Personal email
- **Packages**: Personal development tools
- **Flake target**: `personal` (shared config)

## 🛠️ Development Shells

Isolated development environments without global installation:

| Shell | Command | Includes |
|-------|---------|----------|
| Default | `nix develop` | git, gh, neovim, starship, fish |
| Go | `nix develop .#go` | go, gopls, delve, golangci-lint |
| Python | `nix develop .#python` | python 3.13, uv, ruff, pyright |
| Rust | `nix develop .#rust` | rustc, cargo, rust-analyzer, clippy |
| Node | `nix develop .#node` | node 22, pnpm, yarn, typescript |
| Full | `nix develop .#full` | All languages + databases + cloud tools |

### Example Usage
```bash
# Working on a Go project
cd ~/src/my-go-project
nix develop ~/.config/nix-darwin#go
# Now go, gopls, delve are available
# Exit shell when done - tools are gone

# Need multiple languages
nix develop ~/.config/nix-darwin#full
```

## 🔧 Configuration

### Package Management Strategy
- **Nix packages**: CLI tools, development utilities, libraries
- **Homebrew casks**: GUI applications (via nix-darwin's homebrew module)
- **Chezmoi**: Dotfiles, SSH configs, private configurations

### Adding Packages
1. Determine scope:
   - Universal → `modules/home-common.nix`
   - Work only → `home-work.nix`
   - Personal only → `home-personal.nix`

2. Add to appropriate section and rebuild:
   ```bash
   nrb  # Test build
   nrs  # Apply if successful
   ```

### Custom Options
The configuration uses a custom options pattern:
```nix
options.alankrit = {
  isWork = lib.mkOption { type = lib.types.bool; };
  machineType = lib.mkOption { 
    type = lib.types.enum ["work-laptop" "personal-desktop"];
  };
};
```

## 🐛 Troubleshooting

### Common Issues

**Conflicting files in /etc**
```bash
# Move conflicting files
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
```

**Path not found errors**
```bash
# Ensure chezmoi has applied changes
chezmoi apply
```

**Build failures**
```bash
# Get detailed error trace
darwin-rebuild build --flake .#$(hostname -s) --show-trace
```

### Useful Commands
```bash
# Check flake without building
nix flake check --no-build

# See what would change
darwin-rebuild build --dry-run

# Clean old generations
ngc  # nix-collect-garbage -d

# Review current config
nix repl
:lf .  # load flake
```

## 🚀 Future Plans

See [ROADMAP.md](../../ROADMAP.md) for detailed plans:

1. **Phase 1** ✅: Dev shells, options pattern, documentation
2. **Phase 2**: SSH signing, improved structure
3. **Phase 3**: Arch Linux with Hyprland support
4. **Phase 4**: Advanced features (secrets management, remote deployment)

## 📝 Notes

- Fish shell configuration lives in chezmoi, not nix
- Git configuration is in nix-darwin, not chezmoi
- Aliases auto-detect hostname for correct flake target
- Always test with `build` before `switch`

## 🤝 Contributing

When making changes:
1. Test with `nrb` (build) first
2. Apply with `nrs` (switch) only if build succeeds
3. Follow existing patterns and structure
4. Update this README if adding new features

## 📜 License

Personal configuration - use at your own risk!