{ config, pkgs, lib, ... }:

{
  # Machine-specific configuration for Arch Linux desktop
  alankrit = {
    isWork = false;
    isPersonal = true;
    isLinux = true;
    enableHyprland = true;
    enableGaming = true;
    enable3DPrinting = true;
  };
  
  # Import Linux-specific modules
  imports = [
    ../../modules/common/packages.nix
    ../../modules/linux/packages.nix
    ../../modules/linux/hyprland.nix
  ];
  
  # System configuration
  networking.hostName = "agrani";
  
  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    
    # Latest kernel for better hardware support
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Kernel parameters for performance
    kernelParams = [
      "quiet"
      "splash"
      "nvidia-drm.modeset=1"  # If using NVIDIA
    ];
  };
  
  # Hardware-specific configuration
  hardware = {
    # Enable GPU support (adjust based on your hardware)
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    
    # NVIDIA support (comment out if using AMD)
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
  
  # Filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" ];
  };
  
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
  
  fileSystems."/home" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" ];
  };
  
  swapDevices = [{
    device = "/dev/disk/by-label/swap";
  }];
}