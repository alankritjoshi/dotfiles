{ config, pkgs, lib, inputs, ... }:

{
  # Only enable on Linux systems with Hyprland enabled
  config = lib.mkIf (config.alankrit.isLinux && config.alankrit.enableHyprland) {
    
    # Hyprland and related packages
    environment.systemPackages = with pkgs; [
      # === Core Hyprland Ecosystem ===
      hyprland
      hyprpaper              # Wallpaper
      hypridle               # Idle manager
      hyprlock               # Lock screen
      hyprpicker             # Color picker
      
      # === Status Bar & Launchers ===
      waybar                 # Status bar (like macOS menu bar)
      rofi-wayland          # Application launcher (like Raycast)
      wofi                   # Alternative launcher
      
      # === Notifications & Clipboard ===
      dunst                  # Notification daemon
      wl-clipboard          # Wayland clipboard
      cliphist              # Clipboard history
      
      # === Screenshot & Recording ===
      grimblast             # Screenshot tool
      grim                  # Screenshot backend
      slurp                 # Region selector
      wf-recorder           # Screen recording
      
      # === System Tray & Utilities ===
      network-manager-applet # Network management
      blueman               # Bluetooth management
      pavucontrol           # Audio control
      playerctl             # Media controls
      brightnessctl         # Brightness control
      
      # === File Managers ===
      nautilus              # GUI file manager
      thunar                # Lightweight file manager
      
      # === Theming ===
      catppuccin-gtk        # GTK theme
      papirus-icon-theme    # Icon theme
      bibata-cursors        # Cursor theme
      
      # === Wayland Tools ===
      wlr-randr             # Display configuration
      wdisplays             # GUI display configuration
      wev                   # Wayland event viewer
      
      # === Authentication ===
      polkit-kde-agent      # Authentication agent
      
      # === XDG Desktop Portal ===
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    
    # Enable Hyprland
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland.enable = true;
    };
    
    # XDG portal configuration
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };
    
    # Sound
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    
    # Enable necessary services
    services = {
      dbus.enable = true;
      gnome.gnome-keyring.enable = true;
      
      # Display manager
      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.hyprland}/bin/Hyprland";
            user = "alankritjoshi";
          };
        };
      };
    };
    
    # Fonts
    fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" ]; })
      font-awesome
      noto-fonts
      noto-fonts-emoji
    ];
  };
}