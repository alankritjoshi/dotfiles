{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ./modules/home-common.nix
  ];

  # Personal-specific git configuration
  programs.git = {
    userEmail = "alankritjoshi@gmail.com";
  };

  # Personal-specific packages from nixpkgs
  home.packages = with pkgs; [
    # Communication
    discord
    
    # Media
    plex
    qbittorrent
    
    # VPN
    protonvpn-gui
    
    # Utilities
    keycastr
    keymapp
  ];
}