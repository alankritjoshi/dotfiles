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
      
      # Launch Services
      LaunchServices.LSQuarantine = false;
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
  # This populates /etc/shells and allows using these shells
  environment.shells = with pkgs; [
    bash
    zsh
    fish
  ];
  
  # Enable Fish shell system-wide
  programs.fish.enable = true;
  
  # Set Fish as default shell for the primary user
  users.users.${config.system.primaryUser} = {
    home = "/Users/${config.system.primaryUser}";
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