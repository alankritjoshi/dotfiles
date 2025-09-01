{ config, pkgs, lib, ... }:

{
  # Rofi configuration
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        background = mkLiteral "#1e1e2e";
        background-alt = mkLiteral "#313244";
        foreground = mkLiteral "#cdd6f4";
        selected = mkLiteral "#89b4fa";
        active = mkLiteral "#a6e3a1";
        urgent = mkLiteral "#f38ba8";
      };
      
      "window" = {
        transparency = "real";
        location = mkLiteral "center";
        anchor = mkLiteral "center";
        fullscreen = mkLiteral "false";
        width = mkLiteral "600px";
        x-offset = mkLiteral "0px";
        y-offset = mkLiteral "0px";
        enabled = mkLiteral "true";
        border-radius = mkLiteral "10px";
        cursor = "default";
        background-color = mkLiteral "@background";
      };
      
      "mainbox" = {
        enabled = mkLiteral "true";
        spacing = mkLiteral "0px";
        background-color = mkLiteral "transparent";
        children = mkLiteral "[ inputbar, listbox ]";
      };
      
      "inputbar" = {
        enabled = mkLiteral "true";
        spacing = mkLiteral "10px";
        padding = mkLiteral "15px";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
        children = mkLiteral "[ textbox-prompt-colon, entry ]";
      };
      
      "textbox-prompt-colon" = {
        enabled = mkLiteral "true";
        expand = mkLiteral "false";
        str = "";
        padding = mkLiteral "0px 5px 0px 0px";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
      };
      
      "entry" = {
        enabled = mkLiteral "true";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        cursor = mkLiteral "text";
        placeholder = "Search...";
        placeholder-color = mkLiteral "inherit";
      };
      
      "listbox" = {
        spacing = mkLiteral "0px";
        padding = mkLiteral "0px";
        background-color = mkLiteral "transparent";
        children = mkLiteral "[ listview ]";
      };
      
      "listview" = {
        enabled = mkLiteral "true";
        columns = mkLiteral "1";
        lines = mkLiteral "8";
        cycle = mkLiteral "true";
        dynamic = mkLiteral "true";
        scrollbar = mkLiteral "false";
        layout = mkLiteral "vertical";
        reverse = mkLiteral "false";
        fixed-height = mkLiteral "true";
        fixed-columns = mkLiteral "true";
        spacing = mkLiteral "0px";
        padding = mkLiteral "0px";
        margin = mkLiteral "0px";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
        cursor = "default";
      };
      
      "element" = {
        enabled = mkLiteral "true";
        spacing = mkLiteral "10px";
        padding = mkLiteral "10px";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
        cursor = mkLiteral "pointer";
      };
      
      "element normal.normal" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };
      
      "element selected.normal" = {
        background-color = mkLiteral "@background-alt";
        text-color = mkLiteral "@selected";
      };
      
      "element-text" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        cursor = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.0";
      };
      
      "element-icon" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        size = mkLiteral "24px";
        cursor = mkLiteral "inherit";
      };
    };
    
    extraConfig = {
      modi = "drun,run,window,ssh";
      show-icons = true;
      terminal = "wezterm";
      drun-display-format = "{icon} {name}";
      display-drun = "   Apps ";
      display-run = "   Run ";
      display-window = " 﩯  Window ";
      display-ssh = "   SSH ";
      scroll-method = 0;
      disable-history = false;
      sidebar-mode = true;
    };
  };
  
  # Rofi power menu script
  home.file.".local/bin/rofi-power-menu" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      # Power menu options
      lock="  Lock"
      logout="  Logout"
      suspend="  Suspend"
      reboot="  Reboot"
      shutdown="  Shutdown"
      
      # Get user selection
      selected=$(echo -e "$lock\n$logout\n$suspend\n$reboot\n$shutdown" | rofi -dmenu -p "Power Menu")
      
      case $selected in
        "$lock")
          hyprlock
          ;;
        "$logout")
          hyprctl dispatch exit
          ;;
        "$suspend")
          systemctl suspend
          ;;
        "$reboot")
          systemctl reboot
          ;;
        "$shutdown")
          systemctl poweroff
          ;;
      esac
    '';
  };
}