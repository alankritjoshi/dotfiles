{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ../../modules/home/common.nix
    ../../modules/home/personal.nix
    ../../modules/home/hyprland.nix
  ];
  
  # Machine-specific home configuration
  home.username = username;
  home.homeDirectory = lib.mkForce "/home/${username}";
  home.stateVersion = "24.05";
  
  # Personal git configuration
  programs.git = {
    userEmail = "alankritjoshi@gmail.com";
    signing.key = "~/.ssh/id_ed25519_agrani.pub";
  };
  
  # Linux-specific home packages
  home.packages = with pkgs; [
    # Desktop integration
    xdg-utils
    xdg-user-dirs
    
    # Theming tools
    lxappearance
    qt5ct
    kvantum
    
    # Linux-specific productivity
    flameshot    # Screenshot tool
    peek         # GIF recorder
    
    # System tray apps
    cbatticon    # Battery indicator
    volumeicon   # Volume control
    nm-tray      # Network manager tray
  ];
  
  # XDG configuration
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/*" = "org.gnome.eog.desktop";
        "video/*" = "mpv.desktop";
        "text/plain" = "nvim.desktop";
      };
    };
  };
  
  # GTK configuration
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
  };
  
  # Qt configuration
  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name = "gtk2";
  };
}