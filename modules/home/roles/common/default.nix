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
  };

  environmentVariableExports =
    lib.optionalString config.${namespace}.security.sops.enable
    ''
      if [ -f ${config.sops.secrets.anthropic-api-key.path} ]; then
        export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.anthropic-api-key.path})"
      fi

      if [ -f ${config.sops.secrets.openai-api-key.path} ]; then
        export OPENAI_API_KEY="$(cat ${config.sops.secrets.openai-api-key.path})"
      fi

      if [ -f ${config.sops.secrets.openrouter-api-key.path} ]; then
        export OPENROUTER_API_KEY="$(cat ${config.sops.secrets.openrouter-api-key.path})"
      fi

      if [ -f ${config.sops.secrets.gemini-api-key.path} ]; then
        export GEMINI_API_KEY="$(cat ${config.sops.secrets.gemini-api-key.path})"
      fi

      if [ -f ${config.sops.secrets.tavily-api-key.path} ]; then
        export TAVILY_API_KEY="$(cat ${config.sops.secrets.tavily-api-key.path})"
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
      openai-api-key = {};
      openrouter-api-key = {};
      gemini-api-key = {};
      tavily-api-key = {};
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
          extraInitContent = environmentVariableExports;
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
