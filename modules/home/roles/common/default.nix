{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.roles.common;
in {
  options.roles.common = {
    enable = lib.mkEnableOption "Enable common configuration";
  };

  config = lib.mkIf cfg.enable {
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
        zsh.enable = true;
        nushell.enable = true;
      };
    };

    styles = {
      theming.enable = pkgs.stdenv.isLinux;
    };
  };
}
