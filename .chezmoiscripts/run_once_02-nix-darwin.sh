#!/bin/bash

set -e

echo "Setting up nix-darwin configuration..."

# Get the hostname for the configuration
HOSTNAME=$(hostname -s)
CONFIG_PATH="$HOME/.config/nix-darwin"

# Ensure we're in the right directory
cd "$CONFIG_PATH"

# Check if this is the first run
if ! command -v darwin-rebuild &>/dev/null; then
    echo "First time setup - building nix-darwin..."
    echo ""
    echo "Note: You may be prompted for your password to activate system configuration."
    echo ""
    
    # Build and activate the configuration (will prompt for sudo password when needed)
    nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.${HOSTNAME}.system"
    ./result/sw/bin/darwin-rebuild switch --flake ".#${HOSTNAME}"
    
    echo "nix-darwin installed successfully!"
else
    echo "nix-darwin already installed, rebuilding configuration..."
    
    # Update flake inputs and rebuild
    nix flake update
    darwin-rebuild switch --flake ".#${HOSTNAME}"
fi

echo "Configuration applied successfully!"
echo ""
echo "To manually rebuild in the future, run:"
echo "  darwin-rebuild switch --flake ~/.config/nix-darwin"
echo ""
echo "To update packages, run:"
echo "  nix flake update ~/.config/nix-darwin && darwin-rebuild switch --flake ~/.config/nix-darwin"