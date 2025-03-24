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
  cfg = config.guis.browsers.msedge;
in {
  options.guis.browsers.msedge = {
    enable = mkEnableOption "Enable the Microsoft Edge browser";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.microsoft-edge
    ];
  };
}
