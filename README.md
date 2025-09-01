# Alankrit's Dotfiles

Declarative configuration for Darwin (macOS) and Linux systems using **chezmoi**, **nix** and **home-manager**.

## Prerequisites

### macOS

- **Xcode Command Line Tools** (required for building packages):

  ```bash
  xcode-select --install
  ```

## Quick Setup

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply alankritjoshi
```

This will:

1. Install `chezmoi` and setup dotfiles in `~/.local/share/chezmoi` 
2. Run `chezmoi apply` -> run the `.chezmoiscripts` and sync dotfiles
3. Install Nix and, if a Mac, setup nix-darwin
4. Install common nixpkgs + `brew` and `mas` for Mac packages 
5. Run home manager for some configs that are more nix-like

## Daily Usage

### Modifying existing config

For changes to chezmoi-tracked files:

- Option 1
  - Make changes to the synced config e.g., `~/.config/nvim/init.lua`. Test it out
  - `chezmoi re-add`
- Option 2
  - Make changes and save+push on exit with `chezmoi edit ~/.config/nvim/init.lua`

#### Recommended for

1. Small changes to exiting configuration files tracked by chezmoi
2. Non-nix related changes

### Applying/removing new config

- For additions/removals of files, previous workflow will become annoying as those commands do not work on untracked files
- Previous workflow doesn't run chezmoi scripts that are sometimes necessary
- `chezmoi add <new file>` and `chezmoi destroy` will have to be used in confunction with `chezmoi re-add`

Instead, do:

1. `chezmoi cd` - to `cd` into `~/.local/share/chezmoi` which is source of truth from remote and includes all the scripts
2. Make any changes - add, delete, edit. Note that it won't be effective in the system yet
3. Sync to system and make the changes effective with `chezmoi apply`

#### Recommended for

1. Large changes to Neovim configuration, including addition/removal of plugins
2. Any changes to nix configuration, as those changes typically require execution of scripts

### Update

If dotfiles remote is ahead of configuration on the device, run `chezmoi update` to pull and apply the remote changes

### Update nix packages

```bash
nix flake update
```

### Apply without scripts

Sometimes, especially when debugging, script execution may need to be excluded

```bash
chezmoi apply --exclude scripts
```

## Architecture

```
~/.local/share/chezmoi/           # Dotfiles repo
├── private_dot_config/
│   ├── nix/                                          # System configuration
│   │   ├── flake.nix                                 # Main flake
│   │   ├── devshell.nix                              # Dev shells
│   │   ├── machines/                                 # Machine configs
│   │   └── modules/                                  # Modular configs
│   ├── fish/                                         # Fish shell
│   ├── aerospace/                                    # Window manager
│   └── nvim/                                         # Neovim config
├── key.txt.age                                       # Rage `passphrase` encrypted key
├── private_dot_ssh/
│   └── encrypted_private_id_ed25519_*.age            # Rage `Key` encrypted SSH Keys
├── .chezmoiscripts/                                  # Bootstrap scripts
└── CLAUDE.md                                         # AI assistant guide
```

## SSH Key Management

### How encryption was done

1. Main `key.txt` was generated and `rage` encrypted with passphrase as `key.txt.age`
2. SSH Key pair was generated for each machine
3. Main `key.txt` was used to `rage` encrypt SSH keys in `.private_dot_ssh`

### How decryption works

1. First time setup script run by chezmoi prompts user for passphrase to rage decrypt `key.txt.age`
2. Once decrypted in `~/key.txt`, chezmoi automatically uses it to rage decrypt the ssh keys and puts them in `~/.ssh`

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
- **Unknown hostname**: Script will prompt to select configuration

## License

MIT
