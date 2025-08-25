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
    mkDarwinConfiguration = { hostname }:
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
    
  in {
    # Darwin configurations
    darwinConfigurations = {
      # Work laptop (Shopify)
      "vanik" = mkDarwinConfiguration {
        hostname = "vanik";
      };
      
      # Personal MacBook
      "tejas" = mkDarwinConfiguration {
        hostname = "tejas";
      };
      
      # Personal Mac Mini
      "griha" = mkDarwinConfiguration {
        hostname = "griha";
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
    
    # Development shells for system management
    devShells.${systems.darwin}.default = nixpkgs.legacyPackages.${systems.darwin}.mkShell {
      buildInputs = with nixpkgs.legacyPackages.${systems.darwin}; [
        home-manager.packages.${systems.darwin}.home-manager
        nix-darwin.packages.${systems.darwin}.darwin-rebuild
        nixfmt-rfc-style
      ];
      shellHook = ''
        echo "Nix development shell activated"
        echo ""
        echo "System management commands:"
        echo "  sudo darwin-rebuild switch --flake .          # Apply system configuration"
        echo "  home-manager switch --flake .#$HOST           # Apply home configuration"
        echo ""
        echo "Upgrade commands:"
        echo "  nix flake update                              # Update all flake inputs"
        echo "  nix flake update nixpkgs                      # Update nixpkgs only"
        echo "  nix flake update home-manager                 # Update home-manager only"
        echo "  nix flake update nix-darwin                   # Update nix-darwin only"
        echo ""
        echo "Utilities:"
        echo "  nixfmt *.nix                                  # Format nix files"
        echo "  nix flake check                               # Validate flake configuration"
        echo "  home-manager news --flake .#$HOST             # Read home-manager news"
      '';
    };
  };
}