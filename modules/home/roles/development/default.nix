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

    # TODO: temporary until I create a kanata module
    xdg.configFile."kanata/config.kbd".source = ../../../../kanata/config.kbd;

    cloud.google.enable = true;

    cli = {
      editors.neovim.enable = true;
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
        nh.enable = true;
        podman.enable = true;
        # TODO: need to add more ssh host configs before overriding darwin config
        ssh.enable = !pkgs.stdenv.isDarwin;
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
