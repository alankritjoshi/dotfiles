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
  
  
  # Session variables
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
  };
  
  # Session path
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
    "$HOME/.codeium/windsurf/bin"
  ];
  
  # Disable man page generation to avoid hangs
  programs.man.enable = false;
  manual.manpages.enable = false;

  # User-specific packages
  home.packages = with pkgs; [
    # Development tools
    neovim
    # neovide # Commented out as in original
    lazygit # Was commented in original, but useful for git workflow
    gh # GitHub CLI (config managed by chezmoi)
    
    # Languages and runtimes
    go
    delve
    uv # Python version and package manager
    
    # Dotfiles management
    chezmoi
    age # Encryption tool for secrets
    
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
    # tabiew is in homebrew
    
    # Terminal multiplexers and tools
    zellij
    starship
    
    # Utilities
    gum
    glow
    tldr
    # slides # Commented out as in original
    # marp-cli # Commented out as in original
    
    # Productivity
    hugo # Was commented in original but useful
    
    # System tools
    openssh # includes ssh-copy-id
    openssl
    coreutils
    gnused
    gettext
    autoconf
    bash
    fish
    
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
      if test -f ~/.config/fish/chezmoi_config.fish
        source ~/.config/fish/chezmoi_config.fish
      end
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # Direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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
  
  # Nix-index for command-not-found
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
}