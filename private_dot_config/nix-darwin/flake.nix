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
    
    mkDarwinConfiguration = { hostname, isWork ? false }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        
        modules = [
          ./modules/common.nix
          
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import (if isWork then ./home-work.nix else ./home-personal.nix);
              extraSpecialArgs = { inherit inputs username; };
              backupFileExtension = "backup";
            };
          }
        ];
      };
  in {
    darwinConfigurations = {
      # Work laptop (Shopify)
      "Alankrits-MacBook-Pro" = mkDarwinConfiguration {
        hostname = "Alankrits-MacBook-Pro";
        isWork = true;
      };
      
      # Personal machines (can be used by both Mac Mini and Mac Pro)
      # Use hostname from the machine when building
      "personal" = mkDarwinConfiguration {
        hostname = "personal"; # Will be overridden by actual hostname
        isWork = false;
      };
    };
    
    # Expose the package set for convenience
    darwinPackages = self.darwinConfigurations."Alankrits-MacBook-Pro".pkgs;
  };
}