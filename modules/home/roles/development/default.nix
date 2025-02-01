{
  lib,
  config,
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
