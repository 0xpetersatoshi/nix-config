{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
with types; let
  cfg = config.guis.common;
in {
  options.guis.common = {
    enable = mkEnableOption "Enable common guis";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cava # audio visualizer
      foliate
      keymapp
      pavucontrol
      pwvucontrol
      spotify
      vlc
    ];
  };
}
