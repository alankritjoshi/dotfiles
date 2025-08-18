{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ./modules/home-common.nix
  ];

  # Git configuration for personal machines
  programs.git = {
    enable = true;
    userName = "Alankrit Joshi";
    userEmail = "alankritjoshi@gmail.com";
    
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    
    delta = {
      enable = true;
      options = {
        navigate = true;
        dark = true;
      };
    };
    
    extraConfig = {
      core.editor = "nvim";
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };
}