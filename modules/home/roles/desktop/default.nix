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
      # NOTE: conflicts with stylix when enabled simultaneously
      qt.enable = pkgs.stdenv.isLinux && !config.styles.stylix.enable;
      xdg.enable = true;
    };

    guis = {
      chat.enable = pkgs.stdenv.isLinux;
      browsers.common.enable = pkgs.stdenv.isLinux;
    };

    # allows using Bluetooth headset buttons to control media player
    services.mpris-proxy.enable = true;
  };
}
