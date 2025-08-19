{ config, lib, ... }:

{
  options.alankrit = {
    # Machine type options
    machineType = lib.mkOption {
      type = lib.types.enum [ "work-laptop" "personal-desktop" "personal-laptop" ];
      description = "The type of machine this configuration is for";
    };
    
    # Derived options based on machine type
    isWork = lib.mkOption {
      type = lib.types.bool;
      default = config.alankrit.machineType == "work-laptop";
      description = "Whether this is a work machine";
    };
    
    isPersonal = lib.mkOption {
      type = lib.types.bool;
      default = config.alankrit.machineType != "work-laptop";
      description = "Whether this is a personal machine";
    };
    
    # Platform options
    isDarwin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is a Darwin (macOS) system";
    };
    
    isLinux = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is a Linux system";
    };
    
    # Desktop environment options (Linux)
    enableHyprland = lib.mkOption {
      type = lib.types.bool;
      default = config.alankrit.isLinux;
      description = "Whether to enable Hyprland window manager";
    };
    
    # Feature flags
    enableGaming = lib.mkOption {
      type = lib.types.bool;
      default = config.alankrit.isPersonal && config.alankrit.isLinux;
      description = "Whether to enable gaming-related packages";
    };
    
    enable3DPrinting = lib.mkOption {
      type = lib.types.bool;
      default = config.alankrit.isPersonal;
      description = "Whether to enable 3D printing tools";
    };
  };
}