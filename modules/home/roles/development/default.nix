{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.roles.development;
in {
  options.roles.development = {
    enable = mkEnableOption "Enable development configuration";
  };

  config = mkIf cfg.enable {
    # TODO: find a better spot for this
    xdg = {
      enable = true;
      cacheHome = config.home.homeDirectory + "/.local/cache";
      configHome = config.home.homeDirectory + "/.config";
      stateHome = config.home.homeDirectory + "/.local/state";
      dataHome = config.home.homeDirectory + "/.local/share";
    };

    # TODO: find a better spot for this
    home.sessionPath = ["$HOME/.local/bin"];
    home.file.".local/bin" = {
      source = ../../../../scripts/bin;
      recursive = true;
    };

    # TODO: temporary until I create an nvim module
    xdg.configFile."nvim" = {
      source = ../../../../nvim;
      recursive = true;
    };

    # TODO: temporary until I create a kanata module
    xdg.configFile."kanata/config.kbd".source = ../../../../kanata/config.kbd;

    home.packages = with pkgs; [
      alejandra
      gcc
      libgcc
      nil
    ];

    cloud.google.enable = true;

    cli = {
      multiplexers.zellij.enable = true;
      multiplexers.tmux.enable = true;

      programs = {
        bat.enable = true;
        btop.enable = true;
        direnv.enable = true;
        eza.enable = true;
        fzf.enable = true;
        git.enable = true;
        modern-unix.enable = true;
        network-tools.enable = true;
        podman.enable = true;
        starship.enable = true;
        zoxide.enable = true;
      };

      languages = {
        go.enable = true;
        python.enable = true;
        rust.enable = true;
        typescript.enable = true;
      };
    };
  };
}
