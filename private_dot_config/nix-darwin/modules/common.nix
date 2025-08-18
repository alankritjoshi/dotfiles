{ config, pkgs, inputs, username, hostname, ... }:

{
  imports = [
    ./system.nix
    ./homebrew.nix
    ./packages.nix
  ];

  # Fix nixbld group GID mismatch
  ids.gids.nixbld = 350;
  
  # Necessary for using flakes on this system
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" username ];
    
    # Enable build cache
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    
    # Build performance
    max-jobs = "auto";
    cores = 0; # Use all cores
    sandbox = true;
    warn-dirty = false;
  };
  
  # Optimize nix store automatically
  nix.optimise.automatic = true;
  
  # Garbage collection
  nix.gc = {
    automatic = true;
    interval = { Day = 7; };
    options = "--delete-older-than 30d";
  };

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;
  
  # Enable Fish shell system-wide
  programs.fish.enable = true;
  
  # Set Git commit hash for darwin-version
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility
  system.stateVersion = 4;
  
  # Set primary user for system defaults
  system.primaryUser = username;

  # Platform configuration
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  
  # User configuration
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    description = "Alankrit Joshi";
    shell = pkgs.fish;
  };
  
  # Security - allow passwordless sudo for darwin-rebuild
  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';
}