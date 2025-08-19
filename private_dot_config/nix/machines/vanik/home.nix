{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ../../modules/home/common.nix
    ../../modules/home/work.nix
  ];
  
  # Machine-specific home configuration
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";
  home.stateVersion = "24.05";
  
  # Work-specific git configuration
  programs.git = {
    userEmail = "alankrit.joshi@shopify.com";
  };
  
  # Work-specific packages
  home.packages = with pkgs; [
    # Shopify-specific tools would go here
  ];
}