{ config, pkgs, lib, inputs, username, ... }:

{
  # Personal-specific home configuration
  
  # Personal-specific packages from nixpkgs
  home.packages = with pkgs; [
    # Media
    qbittorrent

  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS personal-specific
    keycastr
    keymapp
    iina
    utm
    
  ] ++ lib.optionals pkgs.stdenv.isLinux [
  ];
  
  # Personal environment variables
  home.sessionVariables = {
    PERSONAL_ENV = "true";
  };
}
