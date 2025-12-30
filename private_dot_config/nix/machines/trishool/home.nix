{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ../../modules/home/common.nix
  ];

  home.username = username;
  home.homeDirectory = lib.mkForce "/home/${username}";
  home.stateVersion = "24.05";

  programs.git.settings = {
    user.email = "alankritjoshi@gmail.com";
    user.signingkey = "~/.ssh/id_ed25519_trishool.pub";
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    git
    gcc
  ];
}
