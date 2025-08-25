#!/bin/bash

set -e

echo "Checking for Nix installation..."

# Skip automatic installation on work machine - dev handles it
if [ "$(hostname -s)" = "vanik" ] && ! command -v nix &>/dev/null; then
    echo "On work machine - please run 'dev' first to install nix"
    echo "Then run 'chezmoi apply' again"
    exit 1
fi

if ! command -v nix &>/dev/null; then
    echo "Nix not found, installing..."
    
    # Install Nix using the Determinate Systems installer (better macOS support)
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    # Source nix profile
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    
    echo "Nix installed successfully!"
else
    echo "Nix is already installed"
fi

echo "Nix version:"
nix --version