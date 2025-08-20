{ config, pkgs, lib, inputs, username, ... }:

{
  # Work-specific home configuration
  
  # Work-specific packages
  home.packages = with pkgs; lib.optionals pkgs.stdenv.isDarwin [
    # macOS work-specific packages
    # Note: Cloudflare Warp is installed via Homebrew cask on macOS
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux work-specific packages
    cloudflare-warp  # Available on Linux via nixpkgs
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
  
  # Work-specific git configuration for dev command
  programs.git.includes = [
    { path = "~/.config/dev-shopify/gitconfig"; }
  ];
}