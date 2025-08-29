{ config, pkgs, lib, ... }:

let
  cfg = config.alankrit.darwin.appearance;
in
{
  options.alankrit.darwin.appearance = {
    enable = lib.mkEnableOption "Darwin appearance settings";
    
    theme = lib.mkOption {
      type = lib.types.enum [ "dark" "light" "auto" ];
      default = "dark";
      description = "System appearance theme";
    };
    
    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to wallpaper image";
      example = "/System/Library/Desktop Pictures/Monterey Graphic.heif";
    };
  };
  
  config = lib.mkIf cfg.enable {
    system.defaults.NSGlobalDomain = lib.mkMerge [
      (lib.mkIf (cfg.theme == "dark") {
        AppleInterfaceStyle = "Dark";
      })
      (lib.mkIf (cfg.theme == "auto") {
        AppleInterfaceStyleSwitchesAutomatically = true;
      })
    ];
    
    # Wallpaper configuration via launchd agent (runs as user, not root)
    launchd.user.agents.set-wallpaper = lib.mkIf (cfg.wallpaper != null) {
      script = ''
        /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to "${cfg.wallpaper}"'
      '';
      serviceConfig = {
        RunAtLoad = true;
        StandardOutPath = "/tmp/wallpaper-set.log";
        StandardErrorPath = "/tmp/wallpaper-set-error.log";
      };
    };
  };
}