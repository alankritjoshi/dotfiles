{ config, pkgs, lib, inputs, username, ... }:

{
  # Work-specific home configuration
  
  # Work-specific packages
  home.packages = with pkgs; lib.optionals pkgs.stdenv.isDarwin [
    # macOS work-specific packages
    cloudflare-warp
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux work-specific packages
    slack
    zoom-us
    teams
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