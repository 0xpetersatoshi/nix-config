{
  lib,
  pkgs,
  config,
  namespace,
  ...
}: let
  shellAliases = {
    cat = "bat";
    ll = "eza --icons=always -l";
    tree = "eza --icons=always --tree";
    v = "nvim";
    z = "zellij";
    grep = "rg";
  };

  tokenExports =
    lib.optionalString config.${namespace}.security.sops.enable
    ''
      if [ -f ${config.sops.secrets.anthropic-api-key.path} ]; then
        export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.anthropic-api-key.path})"
      fi
    '';

  cfg = config.roles.common;
in {
  options.roles.common = {
    enable = lib.mkEnableOption "Enable common configuration";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = lib.mkIf config.${namespace}.security.sops.enable {
      anthropic-api-key = {};
    };

    # GUIs should be managed by homebrew on macOS
    programs.firefox.enable = pkgs.stdenv.isLinux;

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    home.packages = lib.mkIf (!lib.hasAttr "nixos" config) [
      # install as service instead on NixOS
      pkgs._1password-cli
    ];

    guis = {
      # NOTE: only enable on non-nixos linux systems as these apps are managed in nixos modules
      security.enable = !pkgs.stdenv.isDarwin && (!lib.hasAttr "nixos" config);
      browsers.zen.enable = pkgs.stdenv.isLinux;
      productivity.enable = pkgs.stdenv.isLinux;
    };

    cli = {
      terminals = {
        alacritty.enable = true;
        ghostty.enable = true;
        kitty.enable = true;
        wezterm.enable = true;
      };

      shells = {
        zsh = {
          enable = true;
          extraInitContent = tokenExports;
          inherit shellAliases;
        };
        nushell.enable = true;
      };
    };

    styles = {
      theming.enable = pkgs.stdenv.isLinux;
    };
  };
}
