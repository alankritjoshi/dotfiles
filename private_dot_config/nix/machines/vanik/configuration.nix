{ config, pkgs, lib, ... }:

{
  # Machine-specific configuration for work laptop
  alankrit = {
    isWork = true;
    isPersonal = false;
    isDarwin = true;
  };
  
  # Import Darwin-specific modules
  imports = [
    ../../modules/common/packages.nix
    ../../modules/darwin/packages.nix
    ../../modules/darwin/homebrew.nix
  ];
  
  # System configuration
  networking.hostName = "vanik";
  networking.computerName = "vanik";
  
  # Work-specific system settings
  # Enable nix management for work laptop (no Determinate installer)
  nix.enable = true;
}