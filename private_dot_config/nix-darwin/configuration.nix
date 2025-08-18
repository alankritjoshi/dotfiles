{ config, pkgs, inputs, username, hostname, ... }:

{
  imports = [
    ./modules/system.nix
    ./modules/homebrew.nix
    ./modules/packages.nix
  ];

  # Auto upgrade nix package and the daemon service
  services.nix-daemon.enable = true;
  
  # Necessary for using flakes on this system
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" username ];
    
    # Optimize storage automatically
    auto-optimise-store = true;
    
    # Enable build cache
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;
  
  # Enable Fish shell system-wide
  programs.fish.enable = true;
  
  # Set Git commit hash for darwin-version
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility
  system.stateVersion = 4;

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
}