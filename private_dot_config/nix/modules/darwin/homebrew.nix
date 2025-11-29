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
      "uv"      # Python package manager
      "opencode"
    ] ++ lib.optionals config.alankrit.isWork [
      # Work-specific brews can go here
    ] ++ lib.optionals config.alankrit.isPersonal [
      # Personal-specific brews can go here
      "neomutt"
    ];
    
    # GUI applications (casks)
    # Note: Apps requiring macOS system integration should use Homebrew
    casks = [
      # === Common apps for all machines ===
      
      # Security (needs system integration)
      "1password"
      "1password-cli"
      
      # Window management (needs Accessibility permissions)
      "aerospace"
      "shortcat"
      
      # Productivity (needs system integration)
      "raycast"
      "google-drive"
      "voiceink"
      
      # Browsers (needs to register URL schemes)
      "google-chrome"
      "ghostty"

      "codex"

      # System utilities (need system permissions)
      "betterdisplay"     # Display control APIs
      "soundsource"       # Core Audio access
      "daisydisk"         # Full Disk Access
      "stats"             # System monitoring
      "jordanbaird-ice"   # Menu bar control
      "keepingyouawake"   # Power management
      "logi-options+"     # Device management
      "pearcleaner"       # File system access
      
    ] ++ lib.optionals config.alankrit.isWork [
      # === Work-specific apps (Shopify) ===
      
      # Communication & Productivity (not in nixpkgs)
      "slack"
      "fellow"
      "tuple"
      
      # Security & Monitoring (not in nixpkgs)
      # "santa"  # Temporarily disabled due to uninstall issues
      "trailer"
      
      # VPN (required for Shopify access)
      "cloudflare-warp"
      
    ] ++ lib.optionals config.alankrit.isPersonal [
      # === Personal-specific apps ===

      # Productivity (not in nixpkgs)
      "craft"
      "updf"

      # TODO: Add comet browser when available in brew

      # Communication
      "discord"

      # Media
      "plex"
      
      # VPN
      "protonvpn"
      
      # Security & Privacy (not in nixpkgs)
      "radio-silence"
    ];
    
    # Mac App Store apps (personal machines only - requires Apple ID login)
    masApps = lib.optionalAttrs config.alankrit.isPersonal {
      "Klack" = 6446206067;
      "Xcode" = 497799835;
      "Dato" = 1470584107;
      "Encrypto" = 935235287;
    };
  };
}
