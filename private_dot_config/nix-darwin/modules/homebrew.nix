{ config, pkgs, lib, ... }:

{
  homebrew = {
    enable = true;
    
    # Run brew update and upgrade on activation
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";  # Remove anything not in the Brewfile
    };
    
    # Taps
    taps = [
      "nikitabobko/tap"  # For AeroSpace
    ] ++ lib.optionals config.alankrit.isWork [
      # Work-specific taps can go here
    ] ++ lib.optionals config.alankrit.isPersonal [
      # Personal-specific taps can go here
    ];
    
    # Brews (formulae)
    # Only include packages not available in nixpkgs or that work better from Homebrew
    brews = [
      "nvm"     # Node version manager
      "tabiew"  # Table viewer
    ] ++ lib.optionals config.alankrit.isWork [
      # Work-specific brews can go here
    ] ++ lib.optionals config.alankrit.isPersonal [
      # Personal-specific brews can go here
    ];
    
    # GUI applications (casks)
    casks = [
      # === Common apps for all machines ===
      
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
      
    ] ++ lib.optionals config.alankrit.isWork [
      # === Work-specific apps (Shopify) ===
      
      # Communication & Productivity
      "slack"
      "fellow"
      "tuple"
      
      # Security & Monitoring
      "cloudflare-warp"
      "santa"
      "trailer"
      
    ] ++ lib.optionals config.alankrit.isPersonal [
      # === Personal-specific apps ===
      
      # Productivity
      "craft"
      
      # Media
      "iina"
      
      # 3D Printing
      "bambu-studio"
    ];
    
    # Mac App Store apps
    masApps = {
      # Add common Mac App Store apps here if needed
    };
  };
}