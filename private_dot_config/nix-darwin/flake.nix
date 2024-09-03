{
  description = "My Darwin flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
        pkgs.vim
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      # programs.zsh.enable = true;  # default shell on catalina
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      homebrew.enable = true;
      homebrew.taps = [
        { name = "databricks/databricks"; }
        { name = "nikitabobko/aerospace"; }
      ];
      homebrew.casks = [
        "craft"
        "BetterDisplay"
        "shortcat"
        "keymapp"
        "jordanbaird-ice"
        "keepingyouawake"
        "licecap"
        "wezterm"
        "arc"
        "google-chrome"
        "docker"
      ];
      homebrew.brews = [
        "neovim"
        "autoconf"
        "gettext"
        "gnu-sed"
        "git"
        "gh"
        "lazygit"
        "bash"
        "fish"
        "starship"
        "zellij"
        "go"
        "delve"
        "python"
        "node"
        "nvm"
        "pipx"
        "ssh-copy-id"
        "openssl"
        "eza"
        "fzf"
        "zoxide"
        "trash"
        "yazi"
        "fd"
        "sd"
        "ripgrep"
        "bat"
        "gum"
        "glow"
        "slides"
        "marp-cli"
        "hugo"
        "databricks"
        "httpie"
        "xh"
        "jq"
        "fx"
        "htmlq"
        "jless"
        "tabiew"
        "otree"
        "wrk"
        "iperf"
        "oha"
        "aerospace"
      ];
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Joshi-MacBook-Air
    darwinConfigurations."Joshi-MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Joshi-MacBook-Air".pkgs;
  };
}
