{ config, pkgs, ... }:

{
  # Homebrew configuration
  homebrew = {
    enable = true;
    
    # Run brew update and upgrade on activation
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    
    # Taps
    taps = [
      "nikitabobko/tap"
      "homebrew/cask-fonts"
      "homebrew/services"
    ];
    
    # Homebrew packages (formulae)
    # Only include packages not available in nixpkgs or that work better from Homebrew
    brews = [
      "aerospace" # Tiling window manager (not in nixpkgs)
      "1password-cli" # 1Password CLI (proprietary)
    ];
    
    # GUI applications (casks)
    casks = [
      # Development
      "wezterm"
      "docker"
      
      # Browsers
      "google-chrome"
      "arc"
      
      # Productivity
      "raycast"
      "craft"
      "obsidian"
      
      # System utilities
      "stats"
      "betterdisplay"
      "jordanbaird-ice"
      "keepingyouawake"
      "soundsource"
      "daisydisk"
      
      # Window management
      "shortcat"
      
      # Media
      "iina"
      
      # Security
      "1password"
    ];
    
    # Mac App Store apps
    masApps = {
      # "Craft" = 1487937127; # Already using cask version
    };
  };
}