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
  cfg = config.guis.productivity;
in {
  options.guis.productivity = {
    enable = mkEnableOption "Enable productivity guis";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      unstable.dbeaver-bin
      unstable.kdePackages.kcalc
      unstable.morgen
      unstable.obsidian
      unstable.protonmail-desktop
      unstable.qalculate-gtk
      unstable.thunderbird
      unstable.zoom-us
    ];
  };
}
