{ config, pkgs, lib, ... }:

lib.mkIf config.alankrit.isPersonal {
  # Personal-specific Homebrew configuration
  homebrew = {
    # Additional taps for personal use
    taps = [
      # Add personal-specific taps here if needed
    ];
    
    # Additional brews for personal use
    brews = [
      # Add personal-specific brews here if needed
    ];
    
    # Personal-specific GUI applications
    casks = [
      # Productivity
      "craft"
      
      # Media
      "iina"
      
      # 3D Printing
      "bambu-studio"
    ];
  };
}