{ config, pkgs, lib, ... }:

{
  # System-level packages
  environment.systemPackages = with pkgs; [
    # Essential tools
    vim
    git
    curl
    wget
    
    # System utilities
    coreutils
    findutils
    gnugrep
    gnused
    gawk
    
    # Build tools
    cmake
    gnumake
    pkg-config
    
    # Archive tools
    zip
    unzip
    p7zip
    
    # Process management
    htop
    btop
    
    # Network diagnostics
    nmap
    netcat
    
    # Development
    gh # GitHub CLI
    alejandra # Nix code formatter
    
    # Shell
    fish
    bash
    zsh
    
    # === GUI Applications from nixpkgs ===
    
    # Development
    wezterm
    code-cursor
    
    # Window management
    aerospace
    shortcat
    
    # Browsers
    google-chrome
    
    # Productivity
    raycast
    
    # System utilities
    daisydisk
    soundsource
    betterdisplay
    
    # Security
    _1password-gui
    _1password-cli
    
  ] ++ lib.optionals config.alankrit.isWork [
    # Work-specific apps
    cloudflare-warp
    
  ] ++ lib.optionals config.alankrit.isPersonal [
    # Personal-specific apps
    
    # Media
    iina
    
    # 3D Printing
    bambu-studio
  ];
  
  # Environment variables
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
  };
  
  # Shell aliases
  environment.shellAliases = {
    ll = "ls -l";
    la = "ls -la";
    ".." = "cd ..";
    "..." = "cd ../..";
    
    # Git aliases
    g = "git";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git log";
    gd = "git diff";
    
    # Nix aliases
    rebuild = "sudo darwin-rebuild switch --flake ~/.config/nix-darwin";
    update = "nix flake update ~/.config/nix-darwin";
  };
}