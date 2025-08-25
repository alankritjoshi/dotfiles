{ config, pkgs, lib, ... }:

{
  # Minimal system-level packages - only truly system utilities
  environment.systemPackages = with pkgs; [
    # === Core System Tools ===
    vim          # Emergency editor
    git          # Version control (needed for system operations)
    curl         # Network transfer
    wget         # Network download
    openssh      # SSH client/server
    openssl      # Crypto library
    
    # === System Shells ===
    bash         # Default system shell
    zsh          # Alternative system shell
    
    # === Nix Tools ===
    alejandra    # Nix formatter
    nix-index    # Command not found helper
    
  ] ++ lib.optionals config.alankrit.isWork [
    # === Work-specific tools ===
    
  ] ++ lib.optionals config.alankrit.isPersonal [
    # === Personal-specific tools ===
    
  ] ++ lib.optionals config.alankrit.enable3DPrinting [
    # === 3D Printing ===
    # Note: Platform-specific 3D printing apps handled in darwin/linux modules
  ];
}