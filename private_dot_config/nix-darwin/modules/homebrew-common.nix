{ config, pkgs, lib, ... }:

{
  # Common Homebrew configuration for all machines
  homebrew = {
    enable = true;
    
    # Run brew update and upgrade on activation
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";  # Remove anything not in the Brewfile
    };
    
    # Common taps
    taps = [
      "nikitabobko/tap"  # For AeroSpace
    ];
    
    # Common brews (formulae)
    # Only include packages not available in nixpkgs or that work better from Homebrew
    brews = [
      "nvm"     # Node version manager
      "tabiew"  # Table viewer
    ];
    
    # Common GUI applications (casks) for all machines
    casks = [
      # Development
      "wezterm"
      "cursor"
      
      # Window management
      "aerospace"
      "shortcat"
      
      # Browsers
      "google-chrome"
      
      # Productivity
      "raycast"
      "google-drive"
      
      # System utilities
      "stats"
      "betterdisplay"
      "jordanbaird-ice"
      "keepingyouawake"
      "soundsource"
      "daisydisk"
      "logi-options+"
      
      # Security
      "1password"
      "1password-cli"
    ];
    
    # Mac App Store apps
    masApps = {
      # Add common Mac App Store apps here if needed
    };
  };
}