{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.shells.zsh;

  # TODO: Define this in a common module
  shellAliases = {
    cat = "bat";
    ll = "eza --icons=always -l";
    tree = "eza --icons=always --tree";
    v = "nvim";
    z = "zellij";
  };

  homebrewInitExtra = ''
    # Setup the brew package manager for GUI apps
    if [[ -f "/opt/homebrew/bin/brew" ]] then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  '';
in {
  options.cli.shells.zsh = with types; {
    enable = mkBoolOpt false "enable zsh shell";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      # TODO: create a proper package for foundryup
      envExtra = ''
        export PATH="$PATH:${config.xdg.configHome}/.foundry/bin"
      '';

      initContent = ''
        ${
          if pkgs.stdenv.isDarwin
          then homebrewInitExtra
          else ""
        }

        # Functions
        _zellij_update_tabname() {
            if [[ -n $ZELLIJ ]]; then
                if [[ $PWD == $HOME ]]; then
                    nohup zellij action rename-tab "~" >/dev/null 2>&1
                else
                    nohup zellij action rename-tab "$(basename $PWD)" >/dev/null 2>&1
                fi
            fi
        }
        # Add this to your precmd hooks to run before each prompt
        autoload -Uz add-zsh-hook
        add-zsh-hook precmd _zellij_update_tabname


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
  };
}
