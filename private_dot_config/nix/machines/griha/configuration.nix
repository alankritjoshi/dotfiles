{ config, pkgs, lib, ... }:

{
  # Machine-specific configuration for Mac Mini
  alankrit = {
    isWork = false;
    isPersonal = true;
    isDarwin = true;
  };
  
  # Import Darwin-specific modules
  imports = [
    ../../modules/common/packages.nix
    ../../modules/darwin/packages.nix
    ../../modules/darwin/homebrew.nix
  ];
  
  # System configuration
  networking.hostName = "griha";
  networking.computerName = "griha";
}