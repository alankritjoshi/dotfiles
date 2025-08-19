{
  description = "Alankrit's Multi-platform Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # Darwin support
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hyprland (for Linux)
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, hyprland, ... }:
  let
    username = "alankritjoshi";
    
    # System types
    systems = {
      darwin = "aarch64-darwin";
      linux = "x86_64-linux";
    };
    
    # Helper function for Darwin configurations
    mkDarwinConfiguration = { hostname, machineType }:
      nix-darwin.lib.darwinSystem {
        system = systems.darwin;
        specialArgs = { inherit inputs username hostname; };
        
        modules = [
          ./modules/darwin/system.nix
          ./modules/common/options.nix
          ./machines/${hostname}/configuration.nix
          
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./machines/${hostname}/home.nix;
              extraSpecialArgs = { inherit inputs username; };
              backupFileExtension = "backup";
            };
          }
        ];
      };
    
    # Helper function for NixOS configurations (future)
    mkNixosConfiguration = { hostname, machineType }:
      nixpkgs.lib.nixosSystem {
        system = systems.linux;
        specialArgs = { inherit inputs username hostname; };
        
        modules = [
          ./modules/linux/system.nix
          ./modules/common/options.nix
          ./machines/${hostname}/configuration.nix
          ./machines/${hostname}/hardware.nix
          
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./machines/${hostname}/home.nix;
              extraSpecialArgs = { inherit inputs username hyprland; };
              backupFileExtension = "backup";
            };
          }
        ];
      };
    
    # Import devshell configuration
    devshellConfig = import ./devshell.nix { 
      inherit nixpkgs;
      system = systems.darwin; # Default to darwin for now
    };
  in {
    # Darwin configurations
    darwinConfigurations = {
      # Work laptop (Shopify)
      "Alankrits-MacBook-Pro" = mkDarwinConfiguration {
        hostname = "Alankrits-MacBook-Pro";
        machineType = "work-laptop";
      };
      
      # Personal Mac Mini
      "mac-mini" = mkDarwinConfiguration {
        hostname = "mac-mini";
        machineType = "personal-desktop";
      };
      
      # Personal Mac Pro
      "mac-pro" = mkDarwinConfiguration {
        hostname = "mac-pro";
        machineType = "personal-desktop";
      };
    };
    
    # NixOS configurations (future)
    nixosConfigurations = {
      # Arch Linux desktop with Hyprland
      "arch-desktop" = mkNixosConfiguration {
        hostname = "arch-desktop";
        machineType = "personal-desktop";
      };
    };
    
    # Development shells
    devShells = devshellConfig.devShells;
  };
}