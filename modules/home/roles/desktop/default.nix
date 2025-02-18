{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.roles.desktop;
in {
  options.roles.desktop = {
    enable = lib.mkEnableOption "Enable desktop configuration";
  };

  config = lib.mkIf cfg.enable {
    desktops.addons = {
      gtk.enable = pkgs.stdenv.isLinux;
      qt.enable = pkgs.stdenv.isLinux;
      xdg.enable = true;
    };

    guis = {
      chat.enable = pkgs.stdenv.isLinux;
      browsers.common.enable = pkgs.stdenv.isLinux;
    };
  };
}
