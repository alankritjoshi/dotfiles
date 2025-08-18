{ nixpkgs, system }:
let
  pkgs = import nixpkgs { 
    inherit system; 
    config.allowUnfree = true;
  };
in
{
  # Development shells for different project types
  devShells.${system} = {
    # Default shell with common tools
    default = pkgs.mkShell {
      buildInputs = with pkgs; [
        # Version control
        git
        gh
        lazygit
        
        # General development
        gnumake
        curl
        wget
        jq
        
        # Editor
        neovim
        
        # Better shell experience
        starship
        fish
      ];
      
      shellHook = ''
        echo "🚀 Development environment activated"
        echo "Available shells: go, python, rust, node, full"
        echo "Use: nix develop .#<shell-name>"
      '';
    };
    
    # Go development
    go = pkgs.mkShell {
      buildInputs = with pkgs; [
        go
        gopls
        delve
        go-tools
        golangci-lint
        
        # Common tools
        git
        neovim
        lazygit
      ];
      
      shellHook = ''
        echo "🐹 Go development environment"
        echo "Go version: $(go version)"
      '';
    };
    
    # Python development
    python = pkgs.mkShell {
      buildInputs = with pkgs; [
        python313
        uv
        ruff
        pyright
        
        # Common tools
        git
        neovim
        lazygit
      ];
      
      shellHook = ''
        echo "🐍 Python development environment"
        echo "Python version: $(python --version)"
        echo "UV available for package management"
      '';
    };
    
    # Rust development
    rust = pkgs.mkShell {
      buildInputs = with pkgs; [
        rustc
        cargo
        rustfmt
        clippy
        rust-analyzer
        
        # Common tools
        git
        neovim
        lazygit
      ];
      
      shellHook = ''
        echo "🦀 Rust development environment"
        echo "Rust version: $(rustc --version)"
      '';
    };
    
    # Node.js development
    node = pkgs.mkShell {
      buildInputs = with pkgs; [
        nodejs_22
        pnpm
        yarn
        nodePackages.typescript
        nodePackages.typescript-language-server
        
        # Common tools
        git
        neovim
        lazygit
      ];
      
      shellHook = ''
        echo "📦 Node.js development environment"
        echo "Node version: $(node --version)"
        echo "pnpm version: $(pnpm --version)"
      '';
    };
    
    # Full stack development (everything)
    full = pkgs.mkShell {
      buildInputs = with pkgs; [
        # Languages
        go
        gopls
        delve
        python313
        uv
        ruff
        nodejs_22
        pnpm
        rustc
        cargo
        
        # Databases
        postgresql_16
        redis
        sqlite
        
        # Cloud/DevOps
        docker-client
        kubectl
        terraform
        awscli2
        
        # Common tools
        git
        gh
        neovim
        lazygit
        tmux
        jq
        curl
        wget
      ];
      
      shellHook = ''
        echo "🛠️  Full stack development environment"
        echo "All language runtimes and tools available"
      '';
    };
  };
}