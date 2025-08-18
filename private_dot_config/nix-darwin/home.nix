{ config, pkgs, inputs, username, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # User-specific packages
  home.packages = with pkgs; [
    # Development tools
    neovim
    lazygit
    
    # Languages and runtimes
    go
    delve
    python3
    python3Packages.pip
    python3Packages.pipx
    
    # Dotfiles management
    chezmoi
    
    # Command line tools
    eza
    fzf
    zoxide
    ripgrep
    fd
    sd
    bat
    trash-cli
    yazi
    
    # Network tools
    httpie
    xh
    jq
    fx
    htmlq
    jless
    
    # Data tools
    miller # mlr command for CSV/JSON
    
    # Terminal multiplexers and tools
    zellij
    starship
    
    # Utilities
    gum
    glow
    tldr
    
    # Productivity
    slides
    hugo
    
    # System tools
    openssh
    openssl
    coreutils
    gnused
    gettext
    autoconf
    
    # Performance testing
    wrk
    iperf
    oha
  ];

  # Fish shell configuration
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Source additional fish config managed by chezmoi
      if test -f ~/.config/fish/config.fish
        source ~/.config/fish/config.fish
      end
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # Git configuration (basic, as detailed config is in chezmoi)
  programs.git = {
    enable = true;
    package = pkgs.git;
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
      };
    };
  };

  # Direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = true;
  };

  # FZF
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  # Zoxide for smart cd
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Bat (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin-mocha";
    };
  };

  # Eza (better ls)
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = "auto";
  };
}