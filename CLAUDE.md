# Claude Development Guide for Alankrit's Dotfiles

## 🚨 CRITICAL RULES

### ALWAYS use chezmoi apply
- **NEVER** run `darwin-rebuild` directly
- **NEVER** run `sudo darwin-rebuild switch`
- **ALWAYS** use `chezmoi apply` - it handles everything correctly
- The chezmoi script already runs darwin-rebuild with proper configuration

### Correct workflow:
```bash
# Make changes to nix config files
# Then apply with:
chezmoi apply

# NOT these:
# ❌ sudo darwin-rebuild switch
# ❌ darwin-rebuild build
# ❌ nrs
```

## 🎯 Alankrit's Preferences

Based on conversation history:
- **Always use chezmoi apply** for applying any configuration changes
- Prefers **nix philosophy** over convenience hacks
- Wants **proper separation** between work and personal
- Explicitly **doesn't want** gitconfig in chezmoi (it's in nix-darwin)
- **Rejected** atuin when suggested
- Gets annoyed by unauthorized changes to scripts
- Uses **Fish shell**, not Zsh or Bash
- Likes **concise, direct** responses without fluff
- Dotfiles repo should use personal email locally

## 📁 Repository Structure

```
~/.local/share/chezmoi/           # Main dotfiles repo
├── private_dot_config/
│   ├── nix-darwin/              # Nix configuration
│   │   ├── flake.nix
│   │   ├── devshell.nix
│   │   ├── modules/
│   │   ├── home-work.nix
│   │   └── home-personal.nix
│   ├── private_fish/            # Fish shell config
│   ├── private_aerospace/       # Aerospace WM
│   └── private_ghostty/         # Ghostty terminal
├── .chezmoiscripts/
│   └── run_02-nix-darwin.sh    # Handles nix-darwin rebuild
└── ROADMAP.md                   # Future plans
```

## 🔧 Key Patterns

### Machine Detection
- Work laptop: `Alankrits-MacBook-Pro`
- Personal machines: Mac Mini and Mac Pro (both use "personal" config)
- Fish aliases auto-detect hostname for correct flake target

### Configuration Management
- **Nix-darwin**: System packages, git config, development tools
- **Chezmoi**: Dotfiles, private configs, SSH keys (encrypted)
- **Homebrew**: GUI applications (via nix-darwin module)

### Git Configuration
- Managed by nix-darwin, NOT chezmoi
- Work: Shopify email with SSH signing
- Personal: Personal email with SSH signing
- Dotfiles repo: Local config with personal email

## 🛠️ Common Tasks

### Applying Configuration Changes
```bash
# After ANY config change:
chezmoi apply

# This automatically:
# 1. Copies files to correct locations
# 2. Runs darwin-rebuild with correct flake
# 3. Handles /etc/nix/nix.conf conflicts
# 4. Applies home-manager changes
```

### Testing Development Shells
```bash
nix develop                    # Default shell
nix develop .#go              # Go development
nix develop .#python          # Python development
```

### Updating Packages
```bash
cd ~/.config/nix-darwin
nix flake update
chezmoi apply
```

## ⚠️ What NOT to do

- ❌ Don't run darwin-rebuild directly
- ❌ Don't manage gitconfig with chezmoi
- ❌ Don't modify scripts without being asked
- ❌ Don't add packages like atuin
- ❌ Don't create unnecessary documentation
- ❌ Don't use verbose/fluffy responses

## 🔐 Secrets Management

SSH keys are encrypted with age using passphrase protection:
- SSH private key stored encrypted in `private_dot_ssh/encrypted_private_id_ed25519.age`
- Single passphrase to decrypt (no key files needed)
- Chezmoi prompts for passphrase during `chezmoi init --apply`
- No dependency on 1Password for git signing

## 📝 Important Notes

- The `/etc/nix/nix.conf` conflict is handled by the chezmoi script
- Always test with `build` before `switch` (handled by chezmoi)
- Fish config includes SSH_AUTH_SOCK setup
- Development shells don't require global installation