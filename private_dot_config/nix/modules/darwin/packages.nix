{ config, pkgs, lib, ... }:

{
  # Darwin-specific system packages
  environment.systemPackages = with pkgs; [
    # === GNU Tools (macOS needs these) ===
    coreutils
    findutils
    gnugrep
    gnused
    gawk
    
    # === Nix Tools ===
    home-manager
  ] ++ lib.optionals config.alankrit.isWork [
    # Work-specific apps
    # Note: Cloudflare Warp is installed via Homebrew cask on macOS
    
  ] ++ lib.optionals config.alankrit.isPersonal [
    # Personal-specific apps
    
    # Media
    iina
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
