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
    };
  };
}