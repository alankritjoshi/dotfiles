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
    hostname = "Alankrits-MacBook-Pro";
    username = "alankritjoshi";
    system = "aarch64-darwin";
    
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in {
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs username hostname; };
      
      modules = [
        ./configuration.nix
        
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ./home.nix;
            extraSpecialArgs = { inherit inputs username; };
          };
        }
      ];
    };
    
    # Expose the package set for convenience
    darwinPackages = self.darwinConfigurations.${hostname}.pkgs;
  };
}