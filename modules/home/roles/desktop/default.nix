{
  lib,
  config,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.roles.desktop;
in {
  options.roles.desktop = {
    enable = lib.mkEnableOption "Enable desktop configuration";
  };

  config = lib.mkIf cfg.enable {
    desktops.addons = {
      xdg.enable = true;
    };

    guis = {
      chat.enable = pkgs.stdenv.isLinux;
      browsers.common.enable = pkgs.stdenv.isLinux;
    };

    home.sessionVariables = {
      OBSIDIAN_VAULT_PATH = "$HOME/obsidian/vault";
    };

    # allows using Bluetooth headset buttons to control media player
    services.mpris-proxy.enable = true;

    ${namespace} = {
      theme = {
        stylix.enable = pkgs.stdenv.isLinux;
      };
    };
  };
}
