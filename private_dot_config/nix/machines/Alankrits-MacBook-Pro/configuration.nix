{ config, pkgs, lib, ... }:

{
  # Machine-specific configuration for work laptop
  alankrit = {
    machineType = "work-laptop";
    isDarwin = true;
  };
  
  # Import Darwin-specific modules
  imports = [
    ../../modules/common/packages.nix
    ../../modules/darwin/packages.nix
    ../../modules/darwin/homebrew.nix
  ];
  
  # System configuration
  networking.hostName = "Alankrits-MacBook-Pro";
  networking.computerName = "Alankrit's MacBook Pro";
  
  # Work-specific system settings
  system.defaults = {
    NSGlobalDomain = {
      # Stricter security for work
      "com.apple.quarantine.check-download" = true;
    };
  };
}