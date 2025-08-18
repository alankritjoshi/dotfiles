{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ./modules/home-common.nix
  ];

  # Work-specific git configuration
  programs.git = {
    userEmail = "alankrit.joshi@shopify.com";
    
    extraConfig = {
      # Include Shopify dev gitconfig
      include.path = "/Users/${username}/.config/dev/gitconfig";
    };
  };
}