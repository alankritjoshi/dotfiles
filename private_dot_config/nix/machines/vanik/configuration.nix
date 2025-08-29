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
  # Let Shopify dev tools manage nix.conf to avoid conflicts
  nix.enable = false;
  
  # Dock configuration for work machine - override default
  system.defaults.dock.persistent-apps = lib.mkForce [
    "/Applications/Nix Apps/WezTerm.app"
    "/Applications/Nix Apps/Cursor.app"
    "/Applications/Google Chrome.app"
    "/Applications/Slack.app"
    "/System/Applications/Music.app"
  ];
}
