{pkgs, ...}: let
  shellAliases = {
    cat = "bat";
    ll = "eza --icons=always -l";
    tree = "eza --icons=always --tree";
    v = "nvim";
  };

  homebrewInitExtra = ''
    # Setup the brew package manager for GUI apps
    if [[ -f "/opt/homebrew/bin/brew" ]] then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  '';
in {
  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      initExtra = ''
        ${
          if pkgs.stdenv.isDarwin
          then homebrewInitExtra
          else ""
        }

        # Completion styling
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

        # Kitty key bindings
        bindkey '\e[H' beginning-of-line
        bindkey '\e[F' end-of-line
      '';

      oh-my-zsh = {
        enable = true;
        plugins = [
          "aws"
          "command-not-found"
          "git"
          "kubectl"
          "sudo"
        ];
      };
      plugins = [
        {
          name = "fzf-tab";
          src = pkgs.fetchFromGitHub {
            owner = "Aloxaf";
            repo = "fzf-tab";
            rev = "v1.1.2";
            sha256 = "Qv8zAiMtrr67CbLRrFjGaPzFZcOiMVEFLg1Z+N6VMhg=";
          };
        }
      ];

      inherit shellAliases;
    };

    nushell = {
      enable = true;
      inherit shellAliases;
    };

    eza = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      options = ["--cmd cd"];
    };
  };

  # Environment variables
  home.sessionVariables = {
    PATH = "$HOME/bin:$PATH";
  };
}
