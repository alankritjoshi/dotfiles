{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ./claude-code.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = username;
  # home.homeDirectory is set in machine-specific home.nix files
  
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
    "$HOME/.npm-global/bin"
  ];

  # Configure npm to use ~/.npm-global for global packages (avoids sudo)
  home.activation.npmConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.nodejs}/bin/npm config set prefix ~/.npm-global
  '';

  # Disable man page generation to avoid hangs
  programs.man.enable = false;
  manual.manpages.enable = false;

  # User-specific packages
  home.packages = with pkgs; [
    # === Development Tools ===
    neovim
    tree-sitter
    sqlite
    # neovide # Commented out as in original
    lazygit
    gh           # GitHub CLI (config managed by chezmoi)
    delta        # Better git diff
    
    # === Languages & Package Managers ===
    go
    delve        # Go debugger
    nodejs       # Includes npm
    bun          # Fast JS runtime
    
    # === Build Tools ===
    cmake
    gnumake
    pkg-config
    autoconf
    gettext
    
    # === Dotfiles Management ===
    chezmoi
    rage         # Rust implementation of age encryption
    
    # === Modern CLI Tools ===
    eza          # Better ls
    bat          # Better cat
    fd           # Better find
    ripgrep      # Better grep
    sd           # Better sed
    fzf          # Fuzzy finder
    zoxide       # Smart cd
    trash-cli    # Safe rm
    yazi         # File manager
    
    # === Network Tools ===
    httpie       # Better curl
    xh           # Rust httpie
    nmap         # Network scanner
    netcat       # Network utility
    wrk          # HTTP benchmarking
    oha          # HTTP load testing
    iperf        # Network performance
    
    # === File & Data Tools ===
    jq           # JSON processor
    fx           # JSON viewer
    htmlq        # HTML processor
    jless        # JSON pager
    miller       # CSV/JSON tool (mlr command)
    # tabiew is in homebrew
    
    # === Terminal & Shell ===
    zellij
    starship
    
    # === System Monitoring ===
    htop
    btop         # Better top
    
    # === Archive Tools ===
    zip
    unzip
    p7zip
    
    # === Documentation & UI ===
    tldr         # Simplified man pages
    glow         # Markdown renderer
    gum          # Shell scripts UI
    # slides # Commented out as in original
    # marp-cli # Commented out as in original
    
    # === Productivity ===
    hugo         # Static site generator
  ];

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
      theme = "Catppuccin Mocha";
    };
    themes = {
      "Catppuccin Mocha" = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "d2bbee4f7e7d5bac63c054e4d8eca57954b31471";
          sha256 = "sha256-x1yqPCWuoBSx/cI94eA+AWwhiSA42cLNUOFJl7qjhmw=";
        };
        file = "themes/Catppuccin Mocha.tmTheme";
      };
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
  
  # Common Git configuration
  programs.git = {
    enable = true;

    # SSH signing configuration
    signing = {
      signByDefault = true;
    };

    # Global gitignore patterns
    ignores = [
      ".tool-version"
      ".vscode/"
      "*.code-workspace"
      "*.idea/"
      "*.iml"
      "*.DS_Store"
      "*.bundle/config"
      ".claude/settings.local.json"
    ];

    # Common git config
    settings = {
      user.name = "Alankrit Joshi";

      # Git aliases
      alias = {
        prune-branches = "!git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D";
      };

      core = {
        editor = "nvim";
        autocrlf = "input";
        fsmonitor = true;
        untrackedcache = true;
      };
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";

      # Better defaults
      push.default = "current";
      push.autoSetupRemote = true;
      pull.rebase = true;
      fetch.prune = true;
      diff.colorMoved = "default";
      rerere.enabled = true;

      # Git LFS
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
    };
  };

  # Delta for better diffs
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      dark = true;
    };
  };
}
