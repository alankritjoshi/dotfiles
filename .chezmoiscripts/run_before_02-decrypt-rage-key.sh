#!/bin/bash
if [ ! -f ~/.config/chezmoi/key.txt ]; then
  echo "Decrypting rage identity key (one-time setup)..."
  mkdir -p ~/.config/chezmoi

  # Source Nix if not already available (handles fresh installations)
  if ! command -v nix &>/dev/null; then
    # Check for Determinate Systems installation
    if [ -x "/nix/var/nix/profiles/default/bin/nix" ]; then
      export PATH="/nix/var/nix/profiles/default/bin:$PATH"
    elif [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
  fi

  # Use rage directly if available, otherwise use nix run
  if command -v rage &>/dev/null; then
    rage -d ~/.local/share/chezmoi/key.txt.age > ~/.config/chezmoi/key.txt
  elif command -v nix &>/dev/null; then
    echo "Using nix run to execute rage..."
    nix run nixpkgs#rage -- -d ~/.local/share/chezmoi/key.txt.age > ~/.config/chezmoi/key.txt
  else
    echo "❌ Neither rage nor nix is available"
    echo "This shouldn't happen - nix should be installed by run_once_before_01-install-nix.sh"
    exit 1
  fi
  
  chmod 600 ~/.config/chezmoi/key.txt
  echo "✅ Rage identity key configured"
fi