{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.alankrit.isLinux {
    environment.systemPackages = with pkgs; [
      # === Linux-specific CLI tools ===
      
      # System management
      lshw                     # Hardware info
      pciutils                 # lspci
      usbutils                 # lsusb
      dmidecode               # System info
      inxi                    # System information tool
      
      # Process management
      lsof
      strace
      ltrace
      
      # File systems
      ncdu                    # Disk usage analyzer
      duf                     # Better df
      dust                    # Better du
      btrfs-progs            # Btrfs utilities
      ntfs3g                 # NTFS support
      exfat-utils           # exFAT support
      
      # Network
      iw                     # Wireless tools
      wireless-tools
      wavemon               # WiFi monitor
      nethogs               # Network traffic by process
      iftop                 # Network traffic monitor
      
      # Power management
      powertop              # Power consumption analyzer
      acpi                  # Battery info
      
      # Hardware control
      lm_sensors           # Temperature sensors
      fancontrol           # Fan control
      nvtop                # NVIDIA GPU monitor
      radeontop           # AMD GPU monitor
      
      # Audio
      alsa-utils
      pulseaudio          # For pactl
      pamixer             # Pulseaudio mixer
      
      # Development
      gdb
      valgrind
      perf-tools
      
      # Containers
      podman              # Docker alternative
      docker-compose
      lazydocker         # Docker TUI (from Omarchy)
      
      # System rescue
      testdisk           # Data recovery
      photorec          # Photo recovery
      ddrescue          # Disk recovery
    ];
    
    # Environment variables specific to Linux
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "google-chrome";
      TERMINAL = "alacritty";
      
      # Wayland-specific
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
    
    # Shell aliases for Linux
    environment.shellAliases = {
      # System management
      sys = "systemctl";
      sysu = "systemctl --user";
      jctl = "journalctl";
      jctlu = "journalctl --user";
      
      # Package management
      nix-gc = "sudo nix-collect-garbage -d";
      
      # Hardware
      sensors = "watch -n 1 sensors";
      gpu-nvidia = "watch -n 1 nvidia-smi";
      gpu-amd = "watch -n 1 radeontop";
      
      # Network
      ports = "sudo netstat -tulpn";
      myip = "curl -s https://ipinfo.io/ip";
      
      # Wayland
      wayland-info = "wl-info";
      xwayland-apps = "xlsclients";
    };
  };
}