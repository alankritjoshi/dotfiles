{
  description = "Alankrit's Darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
  let
    username = "alankritjoshi";
    system = "aarch64-darwin";
    
    mkDarwinConfiguration = { hostname, machineType }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        
        modules = [
          ./modules/options.nix
          ./modules/common.nix
          
          # Set the machine type
          { alankrit.machineType = machineType; }
          
          home-manager.darwinModules.home-manager
          ({ config, ... }: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import (
                if config.alankrit.isWork then ./home-work.nix else ./home-personal.nix
              );
              extraSpecialArgs = { inherit inputs username; };
              backupFileExtension = "backup";
            };
          })
        ];
      };
    
    # Import devshell configuration
    devshellConfig = import ./devshell.nix { inherit nixpkgs system; };
  in {
    darwinConfigurations = {
      # Work laptop (Shopify)
      "Alankrits-MacBook-Pro" = mkDarwinConfiguration {
        hostname = "Alankrits-MacBook-Pro";
        machineType = "work-laptop";
      };
      
      # Personal machines (can be used by both Mac Mini and Mac Pro)
      # Use hostname from the machine when building
      "personal" = mkDarwinConfiguration {
        hostname = "personal"; # Will be overridden by actual hostname
        machineType = "personal-desktop";
      };
    };
    
    # Development shells
    devShells = devshellConfig.devShells;
    
    # Expose the package set for convenience
    darwinPackages = self.darwinConfigurations."Alankrits-MacBook-Pro".pkgs;
  };
}