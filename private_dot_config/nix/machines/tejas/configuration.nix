{ config, pkgs, lib, ... }:

{
  # Machine-specific configuration for personal MacBook
  alankrit = {
    machineType = "personal-laptop";
    isDarwin = true;
  };
  
  # Import Darwin-specific modules
  imports = [
    ../../modules/common/packages.nix
    ../../modules/darwin/packages.nix
    ../../modules/darwin/homebrew.nix
  ];
  
  # System configuration
  networking.hostName = "tejas";
  networking.computerName = "tejas";
}