{ config, pkgs, lib, ... }:

{
  # Hyprland configuration for home-manager
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;
    
    settings = {
      # Monitor configuration (adjust for your setup)
      monitor = [
        "DP-1,3440x1440@144,0x0,1"           # Main ultrawide monitor
        "HDMI-A-1,1920x1080@60,3440x0,1"     # Secondary monitor
        ",preferred,auto,1"                   # Fallback for any monitor
      ];
      
      # Execute at launch
      exec-once = [
        "waybar"
        "hyprpaper"
        "dunst"
        "nm-applet"
        "blueman-applet"
        "1password --silent"
        "/usr/lib/polkit-kde-authentication-agent-1"
      ];
      
      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
        };
        sensitivity = 0;
      };
      
      # General configuration
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee) rgba(cba6f7ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
      };
      
      # Decorations
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };
      
      # Animations
      animations = {
        enabled = true;
        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
        ];
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
      
      # Layout configuration
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      
      master = {
        new_is_master = true;
      };
      
      # Window rules
      windowrulev2 = [
        "float,class:^(1Password)$"
        "float,class:^(pavucontrol)$"
        "float,class:^(nm-connection-editor)$"
        "float,class:^(blueman-manager)$"
      ];
      
      # Keybindings
      "$mod" = "SUPER";
      
      bind = [
        # Applications
        "$mod, Return, exec, ghostty"
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, E, exec, nautilus"
        "$mod, V, togglefloating"
        "$mod, R, exec, rofi -show drun"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"
        "$mod, F, fullscreen"
        
        # Focus movement (vim-like)
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"
        
        # Window movement
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"
        
        # Workspace switching
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        
        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        
        # Special workspace (scratchpad)
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"
        
        # Scroll through workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
        
        # Screenshots
        ", Print, exec, grimblast --notify copy area"
        "SHIFT, Print, exec, grimblast --notify copy screen"
        
        # Media controls
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        
        # Brightness
        ", XF86MonBrightnessUp, exec, brightnessctl s +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];
      
      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      
      # Resize mode
      bind = [
        "$mod, R, submap, resize"
      ];
      
      submap = "resize";
      
      binde = [
        ", h, resizeactive, -10 0"
        ", l, resizeactive, 10 0"
        ", k, resizeactive, 0 -10"
        ", j, resizeactive, 0 10"
        ", escape, submap, reset"
      ];
      
      submap = "reset";
    };
  };
  
  # Hyprpaper configuration
  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${./wallpaper.jpg}
    wallpaper = ,${./wallpaper.jpg}
    splash = false
  '';
}
