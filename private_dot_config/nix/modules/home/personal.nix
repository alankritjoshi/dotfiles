{ config, pkgs, lib, inputs, username, ... }:

{
  # Personal-specific home configuration
  
  # Personal-specific packages from nixpkgs
  home.packages = with pkgs; [
    # Communication
    discord
    
    # Media
    qbittorrent
    
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS personal-specific
    keycastr
    keymapp
    iina
    
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux personal-specific
    obs-studio
    kdenlive
    audacity
  ];
  
  # Personal environment variables
  home.sessionVariables = {
    PERSONAL_ENV = "true";
  };
}