{ config, pkgs, lib, ... }:

{
  # Set platform flag
  alankrit.isLinux = true;
  
  # Linux-specific system configuration
  config = lib.mkIf config.alankrit.isLinux {
    
    # System packages - Linux equivalents of macOS apps
    environment.systemPackages = with pkgs; [
      # === Development ===
      vscode                    # VSCode (equivalent to cursor)
      neovide                   # Neovim GUI
      
      # === Browsers ===
      google-chrome
      firefox
      brave
      
      # === Communication ===
      discord
      element-desktop           # Matrix client
      signal-desktop
      
      # === Productivity ===
      obsidian                  # Note-taking (from Omarchy)
      typora                    # Markdown editor (from Omarchy)
      libreoffice              # Office suite
      thunderbird              # Email client
      
      # === Media ===
      spotify
      vlc                      # Media player (Linux equivalent of IINA)
      mpv                      # Lightweight media player
      plex-media-player        # Plex client
      jellyfin-media-player    # Open-source alternative
      qbittorrent
      
      # === Graphics & Design ===
      gimp                     # Image editing
      inkscape                 # Vector graphics
      pinta                    # Simple image editor (from Omarchy)
      flameshot                # Screenshot tool
      
      # === System Utilities ===
      gnome-system-monitor     # System monitor (like Stats on macOS)
      baobab                   # Disk usage analyzer (like DaisyDisk)
      gparted                  # Partition manager
      ventoy                   # Bootable USB creator
      
      # === Security & Privacy ===
      _1password-gui
      _1password-cli
      protonvpn-gui
      keepassxc                # Alternative password manager
      veracrypt                # Disk encryption
      
      # === File Sharing ===
      localsend                # Cross-platform file sharing (from Omarchy)
      syncthing                # File synchronization
      
      # === Virtualization ===
      virt-manager             # VM management
      
      # === Package Management ===
      flatpak
      appimage-run
      
    ] ++ lib.optionals config.alankrit.isWork [
      # === Work-specific (Linux) ===
      slack
      zoom-us
      teams
      
    ] ++ lib.optionals config.alankrit.isPersonal [
      # === Personal-specific (Linux) ===
      
      # Media Creation
      obs-studio               # Streaming/recording
      kdenlive                 # Video editing
      audacity                 # Audio editing
      
      # Gaming (if enabled)
    ] ++ lib.optionals config.alankrit.enableGaming [
      # === Gaming ===
      steam
      lutris                   # Game launcher
      mangohud                 # Performance overlay
      gamemode                 # Performance optimizer
      
    ] ++ lib.optionals config.alankrit.enable3DPrinting [
      # === 3D Printing ===
      prusa-slicer
      freecad
      openscad
      cura
    ];
    
    # Essential system configuration
    time.timeZone = "America/Los_Angeles";
    i18n.defaultLocale = "en_US.UTF-8";
    
    # Networking
    networking = {
      networkmanager.enable = true;
      firewall = {
        enable = true;
        allowedTCPPorts = [ 22 ];  # SSH
      };
    };
    
    # Enable CUPS for printing
    services.printing.enable = true;
    
    # Enable sound with pipewire (configured in hyprland.nix)
    
    # Enable touchpad support
    services.xserver.libinput.enable = true;
    
    # System services
    services = {
      # SSH daemon
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };
      
      # Flatpak support
      flatpak.enable = true;
      
      # Bluetooth
      blueman.enable = true;
      
      # Power management
      upower.enable = true;
      thermald.enable = true;
      
      # SSD optimization
      fstrim.enable = true;
    };
    
    # Hardware support
    hardware = {
      bluetooth.enable = true;
      bluetooth.powerOnBoot = true;
    };
    
    # Enable systemd-resolved for DNS
    services.resolved.enable = true;
    
    # Security
    security = {
      polkit.enable = true;
      
      # Allow wheel group to use sudo
      sudo = {
        enable = true;
        wheelNeedsPassword = true;
      };
    };
    
    # User configuration
    users.users.alankritjoshi = {
      isNormalUser = true;
      description = "Alankrit Joshi";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" ];
      shell = pkgs.fish;
    };
    
    # Enable fish shell system-wide
    programs.fish.enable = true;
    
    # Docker support
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
    };
  };
}