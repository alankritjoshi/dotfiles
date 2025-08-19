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
    
    # Development (work fine from nixpkgs)
    wezterm
    code-cursor
    
  ] ++ lib.optionals config.alankrit.isWork [
    # Work-specific apps
    # Note: Cloudflare Warp is installed via Homebrew cask on macOS
    
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