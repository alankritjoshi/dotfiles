{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ../../modules/home/common.nix
    ./claude-code.nix
  ];
  
  # Machine-specific home configuration
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";
  home.stateVersion = "24.05";
  
  # Git configuration for work machine (integrates with dev)
  programs.git = {
    userEmail = "alankrit.joshi@shopify.com";
    extraConfig.maintenance.repo = "/Users/${username}/world/trees/root/src";
    includes = [
      { path = "/Users/${username}/.config/dev/gitconfig"; }
    ];
  };
  
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
