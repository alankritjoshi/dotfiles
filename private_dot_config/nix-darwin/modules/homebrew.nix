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
      # "databricks/databricks" # Uncomment if needed
    ];
    
    # Homebrew packages (formulae)
    # Only include packages not available in nixpkgs or that work better from Homebrew
    brews = [
      "nvm" # Node version manager
      "tabiew" # Table viewer
      # "databricks" # Uncomment if needed
    ];
    
    # GUI applications (casks)
    casks = [
      # Development
      "wezterm"
      
      # Window management
      "aerospace"
      
      # Browsers
      "google-chrome"
      "arc"
      # "zen-browser" # Commented out as in original
      
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
      # "keymapp" # Commented out as in original
      # "licecap" # Commented out as in original
      # "mouseless" # Commented out as in original
      # "leader-key" # Commented out as in original
      # "homerow" # Commented out as in original
      
      # Window management
      "shortcat"
      
      # Media
      "iina"
      
      # Security
      "1password"
      "1password-cli"
    ];
    
    # Mac App Store apps
    masApps = {
      # "Craft" = 1487937127; # Already using cask version
    };
  };
}