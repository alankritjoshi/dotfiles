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

    overlays = [
      (import ./overlays/fish-disable-checks.nix)
    ];

    pkgsFor = system:
      import nixpkgs {
        inherit system overlays;
        config = {
          allowUnfree = true;
        };
      };
    
    # Helper function for Darwin configurations
    mkDarwinConfiguration = { hostname }:
      nix-darwin.lib.darwinSystem {
        system = systems.darwin;
        specialArgs = { inherit inputs username hostname; };
        
        modules = [
          { nixpkgs.overlays = overlays; }
          ./modules/darwin/system.nix
          ./modules/common/options.nix
          ./machines/${hostname}/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./machines/${hostname}/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs username; };
          }
        ];
      };
    
    # Helper function for Home Manager configurations
    mkHomeConfiguration = { hostname, system }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor system;
        extraSpecialArgs = { inherit inputs username; };
        modules = [
          ./machines/${hostname}/home.nix
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
    
    # Home Manager configurations (for standalone use)
    homeConfigurations = {
      # Darwin machines (can be used for faster iteration without sudo)
      "${username}@vanik" = mkHomeConfiguration {
        hostname = "vanik";
        system = systems.darwin;
      };
      
      "${username}@tejas" = mkHomeConfiguration {
        hostname = "tejas";
        system = systems.darwin;
      };
      
      "${username}@griha" = mkHomeConfiguration {
        hostname = "griha";
        system = systems.darwin;
      };
      
      # Arch Linux desktop
      "${username}@agrani" = mkHomeConfiguration {
        hostname = "agrani";
        system = systems.linux;
      };
    };
    
    # Development shells for system management
    devShells.${systems.darwin}.default =
      let darwinPkgs = pkgsFor systems.darwin; in
      darwinPkgs.mkShell {
      buildInputs = with darwinPkgs; [
        home-manager.packages.${systems.darwin}.home-manager
        nix-darwin.packages.${systems.darwin}.darwin-rebuild
        nixfmt-rfc-style
      ];
      shellHook = ''
        echo "Nix development shell activated"
        echo ""
        echo "System management commands:"
        echo "  sudo darwin-rebuild switch --flake .          # Apply system + home config (Darwin)"
        echo "  home-manager switch --flake .#$USER@$(hostname)     # Apply home config only (faster iteration)"
        echo ""
        echo "Note: On Darwin, home-manager is integrated with darwin-rebuild but can still"
        echo "      be used separately for faster user-level changes without sudo"
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
      '';
    };
  };
}
