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
      libreoffice
      morgen
      obsidian
      protonmail-desktop
      thunderbird
      zoom-us
    ];
  };
}
