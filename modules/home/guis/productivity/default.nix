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
      dbeaver-bin
      morgen
      obsidian
      stable.protonmail-desktop
      qalculate-gtk
      thunderbird
      zoom-us
    ];
  };
}
