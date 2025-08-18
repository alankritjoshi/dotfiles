# Nix Configuration Roadmap

## 🎯 Vision
Transform current Darwin-only nix configuration into a multi-platform setup supporting macOS (current) and Arch Linux with Hyprland (future), while maintaining simplicity and incorporating best practices from modern nix configurations.

## 📅 Phase 1: Foundation Improvements (Immediate)

### 1.1 Development Shell Support
**Goal:** Add `nix develop` capability for project-specific environments

**Implementation:**
```nix
# ~/.local/share/chezmoi/private_dot_config/nix-darwin/devshell.nix
{
  devShells.${system}.default = pkgs.mkShell {
    buildInputs = [ go python uv rust nodejs ];
    shellHook = "echo '🚀 Dev environment activated'";
  };
}
```

**Tasks:**
- [ ] Create devshell.nix with common development tools
- [ ] Add flake output for development shells
- [ ] Test with `nix develop` command

### 1.2 Options Pattern for Work/Personal
**Goal:** Replace boolean flags with proper NixOS module options

**Implementation:**
```nix
# modules/options.nix
options.alankrit = {
  isWork = lib.mkOption { type = lib.types.bool; default = false; };
  isPersonal = lib.mkOption { type = lib.types.bool; default = false; };
  enableLinuxDesktop = lib.mkOption { type = lib.types.bool; default = false; };
};
```

**Tasks:**
- [ ] Create modules/options.nix
- [ ] Refactor flake.nix to use options pattern
- [ ] Update machine configs to set options instead of passing isWork

### 1.3 SSH Signing for Git
**Goal:** Replace GPG with simpler SSH key signing

**Implementation:**
```nix
programs.git = {
  signing = {
    key = "~/.ssh/id_ed25519.pub";
    signByDefault = true;
  };
  extraConfig = {
    gpg.format = "ssh";
    gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
  };
};
```

**Tasks:**
- [ ] Generate SSH signing key if not exists
- [ ] Create allowed_signers file
- [ ] Update git configuration in home-work.nix and home-personal.nix
- [ ] Test commit signing with SSH

### 1.4 Documentation
**Goal:** Add AI-friendly documentation for consistency

**Tasks:**
- [ ] Create CLAUDE.md with architecture overview
- [ ] Document design decisions and patterns
- [ ] Add common task examples

## 📅 Phase 2: Structure Preparation (Next Week)

### 2.1 Reorganize for Multi-Platform
**Goal:** Prepare directory structure for Linux support

**New Structure:**
```
private_dot_config/nix/
├── flake.nix
├── devshell.nix
├── modules/
│   ├── common/           # Shared across all platforms
│   │   ├── options.nix
│   │   ├── packages.nix
│   │   └── git.nix
│   ├── darwin/           # macOS-specific
│   │   ├── system.nix
│   │   ├── homebrew.nix
│   │   └── aerospace.nix
│   ├── linux/            # Linux-specific (future)
│   │   ├── system.nix
│   │   ├── hyprland.nix
│   │   └── waybar.nix
│   └── home/             # Home-manager modules
│       ├── common.nix
│       ├── work.nix
│       └── personal.nix
├── machines/
│   ├── Alankrits-MacBook-Pro/  # Work laptop
│   ├── mac-mini/                # Personal Mac Mini
│   ├── mac-pro/                 # Personal Mac Pro
│   └── arch-desktop/            # Future Arch machine
└── themes/
    └── catppuccin.nix
```

**Tasks:**
- [ ] Create new directory structure
- [ ] Move existing configs to appropriate locations
- [ ] Update import paths
- [ ] Test builds on all machines

### 2.2 Extract Common Packages
**Goal:** Separate platform-specific from universal packages

**Categories:**
- **Universal:** git, neovim, fish, starship, bat, eza, etc.
- **Darwin-only:** aerospace, iina, mac-specific tools
- **Linux-only:** hyprland, waybar, rofi, dunst (future)

**Tasks:**
- [ ] Create modules/common/packages.nix
- [ ] Move universal packages to common
- [ ] Keep platform-specific in respective modules

## 📅 Phase 3: Linux Foundation (Future - When Arch Machine Ready)

### 3.1 NixOS Configuration
**Goal:** Add NixOS support alongside nix-darwin

**Tasks:**
- [ ] Create nixosConfigurations in flake.nix
- [ ] Add modules/linux/system.nix with base config
- [ ] Configure for Arch Linux as host (nix on top)

### 3.2 Hyprland Setup
**Goal:** Configure Hyprland window manager

**Components:**
- Hyprland (compositor)
- Waybar (status bar)
- Rofi/Wofi (launcher)
- Dunst/Mako (notifications)
- Hyprpaper (wallpaper)
- Hypridle (idle manager)
- Hyprlock (lock screen)

**Tasks:**
- [ ] Create modules/linux/hyprland.nix
- [ ] Port aerospace keybindings to Hyprland
- [ ] Configure Waybar with similar info as macOS menu bar
- [ ] Theme everything with Catppuccin

### 3.3 Theme System
**Goal:** Unified theming across macOS and Linux

**Implementation:**
- Use nix-colors for color schemes
- Apply to: terminals, editors, window managers, bars
- Single source of truth for colors

**Tasks:**
- [ ] Integrate nix-colors
- [ ] Create theme module
- [ ] Apply to all applications

## 📅 Phase 4: Advanced Features (Long-term)

### 4.1 Secrets Management
**Goal:** Manage sensitive data properly

**Options:**
- agenix for encrypted secrets
- 1Password CLI integration
- git-crypt for repository encryption

### 4.2 Remote Deployment
**Goal:** Deploy to machines remotely

**Tools:**
- deploy-rs or nixos-rebuild --target-host
- Tailscale for connectivity

### 4.3 Impermanence
**Goal:** Stateless root filesystem (Linux only)

**Benefits:**
- Clean system state
- Explicit state management
- Easy rollbacks

## 🚀 Quick Wins (Can Do Now)

1. **Auto-format nix files:** Add alejandra/nixpkgs-fmt
2. **Nix helper aliases:** Add more fish abbreviations
3. **Update checker:** Script to check for outdated packages
4. **Build CI:** GitHub Actions for validation

## 📊 Success Metrics

- [ ] Single command to bootstrap any machine
- [ ] Consistent environment across macOS and Linux
- [ ] Development shells for all project types
- [ ] All configuration in git (no manual steps)
- [ ] Clean separation of concerns
- [ ] Easy to add new machines

## 🔄 Migration Strategy

1. **Backup current configuration**
2. **Implement changes incrementally**
3. **Test each phase thoroughly**
4. **Keep rollback ability**
5. **Document everything**

## 📝 Notes

- Keep chezmoi for non-nix configs (SSH keys, etc.)
- Maintain backward compatibility during transition
- Test changes on mac-mini first (personal machine)
- Don't break work laptop configuration

## 🎯 Current Focus

**Week 1 (This Week):**
- Implement Phase 1.1-1.4
- Start Phase 2.1 planning

**Week 2:**
- Complete Phase 2 restructuring
- Prepare Linux module templates

**When Arch Machine Available:**
- Implement Phase 3
- Full multi-platform setup

---

*Last Updated: 2025-01-18*
*Status: Planning Phase 1*