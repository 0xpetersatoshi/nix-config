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
  cfg = config.guis.browsers.common;
in {
  options.guis.browsers.common = {
    enable = mkEnableOption "Enable common browser";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      brave
      ungoogled-chromium
      vivaldi
    ];
  };
}
