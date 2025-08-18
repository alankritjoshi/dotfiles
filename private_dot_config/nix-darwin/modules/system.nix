{ config, pkgs, ... }:

{
  # System settings
  system = {
    defaults = {
      # Finder
      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv"; # Column view
        _FXShowPosixPathInTitle = true;
      };
      
      # Dock
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.5;
        tilesize = 48;
        show-recents = false;
        minimize-to-application = true;
        mru-spaces = false;
      };
      
      # Global macOS settings
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3; # Full keyboard control
        ApplePressAndHoldEnabled = false; # Disable press-and-hold for keys
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        _HIHideMenuBar = false;
      };
      
      # Screenshots
      screencapture.location = "~/Desktop";
      
      # Trackpad
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
      
      # Login window
      loginwindow = {
        GuestEnabled = false;
      };
    };
    
    # Keyboard remapping
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
  
  # Security settings
  security.pam.enableSudoTouchIdAuth = true;
  
  # Fonts
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Meslo" ]; })
    ];
  };
  
  # Enable locate database
  services.locate.enable = true;
}