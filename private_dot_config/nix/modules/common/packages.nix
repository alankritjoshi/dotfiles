{ config, pkgs, lib, ... }:

{
  # Universal packages for all platforms
  environment.systemPackages = with pkgs; [
    # === Core Tools ===
    vim
    neovim
    git
    curl
    wget
    openssh
    openssl
    
    # === Shell & Terminal ===
    fish
    bash
    zsh
    starship
    zellij
    
    # === Modern CLI Tools ===
    eza          # Better ls
    bat          # Better cat
    fd           # Better find
    ripgrep      # Better grep
    sd           # Better sed
    fzf          # Fuzzy finder
    zoxide       # Smart cd
    trash-cli    # Safe rm
    
    # === Development Tools ===
    gh           # GitHub CLI
    lazygit      # Git TUI
    delta        # Better git diff
    
    # Languages & Package Managers
    go
    delve        # Go debugger
    uv           # Python package manager
    nodejs
    bun          # Fast JS runtime
    
    # Build tools
    cmake
    gnumake
    pkg-config
    autoconf
    
    # === File & Data Tools ===
    jq           # JSON processor
    fx           # JSON viewer
    htmlq        # HTML processor
    jless        # JSON pager
    miller       # CSV/JSON tool
    yazi         # File manager
    
    # === Network Tools ===
    httpie       # Better curl
    xh           # Rust httpie
    nmap         # Network scanner
    netcat       # Network utility
    wrk          # HTTP benchmarking
    oha          # HTTP load testing
    iperf        # Network performance
    
    # === System Monitoring ===
    htop
    btop         # Better top
    
    # === Archive Tools ===
    zip
    unzip
    p7zip
    
    # === Documentation ===
    tldr         # Simplified man pages
    glow         # Markdown renderer
    gum          # Shell scripts UI
    
    # === Encryption & Security ===
    age          # Modern encryption
    
    # === Nix Tools ===
    alejandra    # Nix formatter
    nix-index    # Command not found helper
    
    # === Productivity ===
    hugo         # Static site generator
    chezmoi      # Dotfiles manager
    
  ] ++ lib.optionals config.alankrit.isWork [
    # === Work-specific tools ===
    
  ] ++ lib.optionals config.alankrit.isPersonal [
    # === Personal-specific tools ===
    
  ] ++ lib.optionals config.alankrit.enable3DPrinting [
    # === 3D Printing ===
    # Note: Platform-specific 3D printing apps handled in darwin/linux modules
  ];
}