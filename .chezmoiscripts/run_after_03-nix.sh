#!/bin/bash

set -e

echo "Setting up nix configuration..."
# Last updated: $(date)

# Get the hostname for the configuration
HOSTNAME=$(hostname -s)
CONFIG_PATH="$HOME/.config/nix"

# Determine which flake configuration to use
if [ "$HOSTNAME" = "vanik" ]; then
    echo "Detected work laptop - using work configuration"
    FLAKE_TARGET="vanik"
elif [ "$HOSTNAME" = "tejas" ]; then
    echo "Detected personal MacBook - using personal configuration"
    FLAKE_TARGET="tejas"
elif [ "$HOSTNAME" = "griha" ]; then
    echo "Detected Mac Mini - using personal configuration"
    FLAKE_TARGET="griha"
elif [ "$HOSTNAME" = "agrani" ]; then
    echo "Detected Arch Linux desktop - using experimental configuration"
    FLAKE_TARGET="agrani"
elif [ "$HOSTNAME" = "trishool" ]; then
    echo "Detected Ubuntu VM - using minimal configuration"
    FLAKE_TARGET="trishool"
else
    echo "Unknown hostname: $HOSTNAME"
    echo ""
    echo "Please select the machine configuration to use:"
    echo "1) vanik    - Work MacBook (Shopify)"
    echo "2) tejas    - Personal MacBook"
    echo "3) griha    - Mac Mini"
    echo "4) agrani   - Linux Desktop (Arch + Hyprland)"
    echo "5) trishool - Ubuntu VM (minimal)"
    echo ""
    read -p "Enter selection (1-5): " selection
    
    case $selection in
        1) FLAKE_TARGET="vanik"
           echo "Using work configuration (vanik)"
           ;;
        2) FLAKE_TARGET="tejas"
           echo "Using personal MacBook configuration (tejas)"
           ;;
        3) FLAKE_TARGET="griha"
           echo "Using Mac Mini configuration (griha)"
           ;;
        4) FLAKE_TARGET="agrani"
           echo "Using Linux desktop configuration (agrani)"
           ;;
        5) FLAKE_TARGET="trishool"
           echo "Using Ubuntu VM configuration (trishool)"
           ;;
        *) echo "Invalid selection, defaulting to work configuration"
           FLAKE_TARGET="vanik"
           ;;
    esac
fi

# Ensure we're in the right directory
cd "$CONFIG_PATH"

# Source Nix if not already available (handles fresh installations)
if ! command -v nix &>/dev/null; then
    echo "Nix command not found, adding to PATH..."
    
    # Check for Determinate Systems installation
    if [ -x "/nix/var/nix/profiles/default/bin/nix" ]; then
        export PATH="/nix/var/nix/profiles/default/bin:$PATH"
        echo "Added Determinate Nix to PATH"
    # Check for standard Nix installation
    elif [ -x "/run/current-system/sw/bin/nix" ]; then
        export PATH="/run/current-system/sw/bin:$PATH"
        echo "Added system Nix to PATH"
    # Check for single-user installation
    elif [ -x "$HOME/.nix-profile/bin/nix" ]; then
        export PATH="$HOME/.nix-profile/bin:$PATH"
        echo "Added user Nix to PATH"
    else
        echo "Error: Could not find Nix installation"
        echo "Please restart your shell and run 'chezmoi apply' again"
        exit 1
    fi
fi

# Function to run darwin-rebuild with automatic conflict resolution
run_darwin_rebuild() {
    # First attempt
    output=$("$@" 2>&1) && {
        echo "$output"
        return 0
    } || {
        echo "$output"
        
        # If there are /etc conflicts, handle them and retry once
        if echo "$output" | grep -q "Unexpected files in /etc"; then
            echo "Moving conflicting /etc files..."
            echo "$output" | grep "^  /" | sed 's/^  //' | while read -r file; do
                [ -f "$file" ] && sudo mv "$file" "${file}.before-nix-darwin"
            done
            
            # Retry once after moving files
            "$@"
        else
            return 1
        fi
    }
}

# Determine the rebuild command based on platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    REBUILD_CMD="darwin-rebuild"
    CONFIG_TYPE="darwinConfigurations"
elif [ "$FLAKE_TARGET" = "trishool" ]; then
    REBUILD_CMD="home-manager"
    CONFIG_TYPE="homeConfigurations"
    USERNAME=$(whoami)
else
    REBUILD_CMD="nixos-rebuild"
    CONFIG_TYPE="nixosConfigurations"
fi

# Check if this is the first run
if ! command -v $REBUILD_CMD &>/dev/null; then
    echo "First time setup - building nix configuration..."
    echo ""

    if [ "$REBUILD_CMD" = "home-manager" ]; then
        # home-manager standalone setup (no sudo needed)
        echo "Installing home-manager..."
        nix run home-manager/master -- switch --flake ".#${USERNAME}@${FLAKE_TARGET}"
    else
        echo "Note: You may be prompted for your password to activate system configuration."
        echo ""

        # Build and activate the configuration (will prompt for sudo password when needed)
        nix --extra-experimental-features 'nix-command flakes' build ".#${CONFIG_TYPE}.${FLAKE_TARGET}.system"
        run_darwin_rebuild sudo ./result/sw/bin/$REBUILD_CMD switch --flake ".#${FLAKE_TARGET}"
    fi

    echo "Nix configuration installed successfully!"
else
    echo "Nix configuration already installed, rebuilding..."

    if [ "$REBUILD_CMD" = "home-manager" ]; then
        # home-manager doesn't need sudo
        $REBUILD_CMD switch --flake ".#${USERNAME}@${FLAKE_TARGET}"
    else
        # Just rebuild without updating flakes
        run_darwin_rebuild sudo $REBUILD_CMD switch --flake ".#${FLAKE_TARGET}"
    fi
fi

echo "Configuration applied successfully!"
echo ""
echo "To manually rebuild in the future, run:"
if [ "$REBUILD_CMD" = "home-manager" ]; then
    echo "  chezmoi apply                                                      # Apply dotfiles and rebuild"
    echo "  home-manager switch --flake ~/.config/nix#${USERNAME}@${FLAKE_TARGET}  # Just rebuild home config"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  chezmoi apply                                    # Apply dotfiles and rebuild"
    echo "  sudo darwin-rebuild switch --flake ~/.config/nix # Just rebuild nix config"
else
    echo "  chezmoi apply                                     # Apply dotfiles and rebuild"
    echo "  sudo nixos-rebuild switch --flake ~/.config/nix  # Just rebuild nix config"
fi
echo ""
echo "To update packages, run:"
if [ "$REBUILD_CMD" = "home-manager" ]; then
    echo "  cd ~/.config/nix && nix flake update && home-manager switch --flake .#${USERNAME}@${FLAKE_TARGET}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  cd ~/.config/nix && nix flake update && sudo darwin-rebuild switch --flake ."
else
    echo "  cd ~/.config/nix && nix flake update && sudo nixos-rebuild switch --flake ."
fi