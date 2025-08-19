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
    # Note: Apps available in nixpkgs have been moved to packages.nix
    casks = [
      # === Common apps for all machines ===
      
      # Productivity (not in nixpkgs)
      "google-drive"
      
      # System utilities (not in nixpkgs)
      "stats"
      "jordanbaird-ice"
      "keepingyouawake"
      "logi-options+"
      "pearcleaner"
      
    ] ++ lib.optionals config.alankrit.isWork [
      # === Work-specific apps (Shopify) ===
      
      # Communication & Productivity (not in nixpkgs)
      "slack"
      "fellow"
      "tuple"
      
      # Security & Monitoring (not in nixpkgs)
      "santa"
      "trailer"
      
    ] ++ lib.optionals config.alankrit.isPersonal [
      # === Personal-specific apps ===
      
      # Productivity (not in nixpkgs)
      "craft"
      "updf"
      
      # Security & Privacy (not in nixpkgs)
      "radio-silence"
    ];
    
    # Mac App Store apps (personal machines only - requires Apple ID login)
    masApps = lib.optionalAttrs config.alankrit.isPersonal {
      # Personal-specific Mac App Store apps
      "Klack" = 6446206067;
      "Dato" = 1470584107;
      "Encrypto" = 935235287;
    };
  };
}