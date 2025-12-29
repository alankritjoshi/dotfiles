{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ../../modules/home/common.nix
    ../../modules/home/personal.nix
  ];
  
  # Machine-specific home configuration
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";
  home.stateVersion = "24.05";
  
  # Personal git configuration
  programs.git.settings = {
    user.email = "alankritjoshi@gmail.com";
    user.signingkey = "~/.ssh/id_ed25519_griha.pub";
  };
}