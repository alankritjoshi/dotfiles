{ config, pkgs, lib, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Disable nix-darwin's nix management for Determinate Systems compatibility
  # Only enabled on work machines without Determinate
  nix.enable = lib.mkDefault false;
  
  # System settings
  system = {
    # State version for nix-darwin
    stateVersion = 6;
    
    # Primary user for system-wide settings
    primaryUser = "alankritjoshi";
    
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
        autohide-time-modifier = 0.15;
        tilesize = 48;
        show-recents = false;
        minimize-to-application = true;
        mru-spaces = false;
        expose-group-apps = true;
        persistent-apps = [
          "/Applications/Google Chrome.app"
          "/Applications/Nix Apps/WezTerm.app"
          "/Applications/Xcode-beta.app"
          "/System/Applications/iPhone Mirroring.app"
          "/System/Applications/Music.app"
          "/System/Applications/Messages.app"
        ];
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
      
      # Launch Services
      LaunchServices.LSQuarantine = false;
      
      # Spaces (Mission Control)
      spaces.spans-displays = true;  # Mission Control spans across multiple displays
    };
    
    # Keyboard remapping
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
  
  # Security settings
  security.pam.services.sudo_local.touchIdAuth = true;
  
  # Shell configuration
  environment.shells = with pkgs; [ bash zsh fish ];
  programs.fish.enable = true;
  
  # User configuration - this will set the default shell
  # Required for shell changes to take effect on macOS
  # See: https://github.com/nix-darwin/nix-darwin/issues/1237
  users.knownUsers = [ config.system.primaryUser ];
  users.users.${config.system.primaryUser} = {
    uid = 501;  # Standard macOS user ID
    shell = pkgs.fish;
  };
  
  # Fonts
  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
      nerd-fonts.hack
    ];
  };
}
