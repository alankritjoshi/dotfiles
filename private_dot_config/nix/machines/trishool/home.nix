{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ../../modules/home/common.nix
  ];

  home.username = username;
  home.homeDirectory = lib.mkForce "/home/${username}";
  home.stateVersion = "24.05";

  programs.git = {
    userEmail = "alankritjoshi@gmail.com";
    signing.key = "~/.ssh/id_ed25519_trishool.pub";
  };

  # Minimal packages for Ubuntu VM
  home.packages = with pkgs; [
    # Essential tools only
    ripgrep
    fd
    git
  ];
}
