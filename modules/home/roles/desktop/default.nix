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
      # NOTE: conflicts with stylix when gtk/qt enabled simultaneously
      xdg.enable = true;
    };

    guis = {
      chat.enable = pkgs.stdenv.isLinux;
      browsers.common.enable = pkgs.stdenv.isLinux;
    };

    # allows using Bluetooth headset buttons to control media player
    services.mpris-proxy.enable = true;

    igloo = {
      theme = {
        gtk.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
        qt.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
      };
    };
  };
}
