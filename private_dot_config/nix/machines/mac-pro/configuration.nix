{ config, pkgs, lib, ... }:

{
  # Machine-specific configuration for Mac Pro
  alankrit = {
    machineType = "personal-desktop";
    isDarwin = true;
  };
  
  # Import Darwin-specific modules
  imports = [
    ../../modules/common/packages.nix
    ../../modules/darwin/packages.nix
    ../../modules/darwin/homebrew.nix
  ];
  
  # System configuration
  networking.hostName = "mac-pro";
  networking.computerName = "Alankrit's Mac Pro";
}