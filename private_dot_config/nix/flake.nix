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
    
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
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
    
    # Import devshell configuration
    devshellConfig = import ./devshell.nix { 
      inherit nixpkgs;
      system = systems.darwin; # Default to darwin for now
    };
  in {
    # Darwin configurations
    darwinConfigurations = {
      # Work laptop (Shopify)
      "vanik" = mkDarwinConfiguration {
        hostname = "vanik";
        machineType = "work-laptop";
      };
      
      # Personal MacBook
      "tejas" = mkDarwinConfiguration {
        hostname = "tejas";
        machineType = "personal-laptop";
      };
      
      # Personal Mac Mini
      "griha" = mkDarwinConfiguration {
        hostname = "griha";
        machineType = "personal-desktop";
      };
    };
    
    # Standalone Home Manager configurations (for non-NixOS systems)
    homeConfigurations = {
      # Arch Linux desktop
      "${username}@agrani" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${systems.linux};
        extraSpecialArgs = { inherit inputs username; };
        modules = [
          ./machines/agrani/home.nix
        ];
      };
    };
    
    # Development shells
    devShells = devshellConfig.devShells;
  };
}