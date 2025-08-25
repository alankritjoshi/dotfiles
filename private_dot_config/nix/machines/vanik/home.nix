{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ../../modules/home/common.nix
  ];
  
  # Machine-specific home configuration
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";
  home.stateVersion = "24.05";
  
  # Let dev manage git config on work machine
  programs.git.enable = lib.mkForce false;
  
  # Work-specific packages
  home.packages = with pkgs; [
    # Shopify-specific tools would go here
    # Note: Cloudflare Warp is installed via Homebrew cask on macOS
  ];
  
  # Work-specific environment variables
  home.sessionVariables = {
    WORK_ENV = "shopify";
  };
  
  # Work-specific shell aliases
  programs.fish.shellAliases = {
    # Shopify-specific aliases
    dev = "source /opt/dev/dev.fish";
    spin = "dev spin";
  };
}