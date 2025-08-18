{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ./modules/home-common.nix
  ];

  # Personal-specific git configuration
  programs.git = {
    userEmail = "alankritjoshi@gmail.com";
  };
}