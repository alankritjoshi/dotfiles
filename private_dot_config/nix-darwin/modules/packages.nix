{ config, pkgs, ... }:

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
    
    # Shell
    fish
    bash
    zsh
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
    rebuild = "darwin-rebuild switch --flake ~/.config/nix-darwin";
    update = "nix flake update ~/.config/nix-darwin";
  };
}