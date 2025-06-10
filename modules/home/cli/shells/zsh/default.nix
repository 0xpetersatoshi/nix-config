{
  pkgs,
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.shells.zsh;

  homebrewInitExtra = ''
    # Setup the brew package manager for GUI apps
    if [[ -f "/opt/homebrew/bin/brew" ]] then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  '';

  baseInitContent = ''
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
in {
  options.cli.shells.zsh = with types; {
    enable = mkBoolOpt false "enable zsh shell";

    shellAliases = mkOption {
      type = attrsOf str;
      default = {};
      description = "Additional shell aliases to merge with default aliases. User aliases will override defaults if there are conflicts.";
      example = {
        ls = "eza --icons";
        grep = "rg";
      };
    };

    extraInitContent = mkOption {
      type = str;
      default = "";
      description = "Additional lines to add to zsh initContent";
      example = ''
        # Custom functions
        myfunction() {
          echo "Hello from custom function"
        }

        # Custom exports
        export MY_VAR="custom_value"
      '';
    };
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

      initContent = baseInitContent + optionalString (cfg.extraInitContent != "") "\n${cfg.extraInitContent}";

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

      inherit (cfg) shellAliases;
    };
  };
}
