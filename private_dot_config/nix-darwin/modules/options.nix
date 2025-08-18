{ config, lib, ... }:

{
  options.alankrit = {
    isWork = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is a work machine (Shopify)";
    };
    
    isPersonal = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is a personal machine";
    };
    
    enableLinuxDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Linux desktop environment (Hyprland, Waybar, etc.)";
    };
    
    machineType = lib.mkOption {
      type = lib.types.enum [ "work-laptop" "personal-desktop" "personal-laptop" "linux-desktop" ];
      default = "personal-desktop";
      description = "Type of machine for specific configurations";
    };
  };
  
  config = {
    # Automatically set isWork and isPersonal based on machineType
    alankrit.isWork = lib.mkDefault (config.alankrit.machineType == "work-laptop");
    alankrit.isPersonal = lib.mkDefault (lib.elem config.alankrit.machineType [ "personal-desktop" "personal-laptop" ]);
  };
}