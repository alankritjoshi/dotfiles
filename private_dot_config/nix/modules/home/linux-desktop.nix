{ config, pkgs, lib, ... }:

{
  # Linux desktop-specific home configuration
  # This module contains user-level configurations for Linux desktop environments
  
  config = lib.mkIf pkgs.stdenv.isLinux {
    # Import desktop environment configurations
    imports = [
      ./waybar.nix
      ./rofi.nix
    ];
    
    # Linux desktop-specific packages that belong in home-manager
    home.packages = with pkgs; [
      # Development tools (matching Darwin)
      code-cursor            # AI-powered code editor
      
      # Desktop utilities
      xclip                   # X11 clipboard
      wl-clipboard           # Wayland clipboard
      xorg.xkill             # Kill X11 windows
      
      # Media viewers
      feh                    # Image viewer
      mpv                    # Video player
      
      # System monitoring
      conky                  # System monitor
      
      # Notification tools
      libnotify              # Send desktop notifications
      
      # Desktop recording
      obs-studio             # Screen recording/streaming
      
      # File management
      pcmanfm                # Lightweight file manager
      
      # PDF viewer
      zathura                # Lightweight PDF viewer
    ];
    
    # Desktop-specific environment variables
    home.sessionVariables = lib.mkIf config.wayland.windowManager.hyprland.enable {
      # Wayland-specific variables for user session
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };
    
    # Desktop file associations
    xdg.mimeApps = {
      enable = true;
      associations.added = {
        "application/pdf" = ["org.pwmt.zathura.desktop"];
        "image/*" = ["feh.desktop"];
        "video/*" = ["mpv.desktop"];
      };
    };
    
    # Fontconfig for better font rendering
    fonts.fontconfig.enable = true;
    
    # Enable desktop portals for better integration
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
}