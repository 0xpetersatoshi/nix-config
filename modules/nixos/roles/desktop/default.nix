{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.desktop;
in {
  options.roles.desktop = {
    enable = mkEnableOption "Enable desktop configuration";
  };

  config = mkIf cfg.enable {
    boot.binfmt.emulatedSystems = ["aarch64-linux"];

    # NOTE: enables portal definitions and DE provided configurations to get linked
    # https://home-manager-options.extranix.com/?query=xdg.portal.enable&release=master
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
      "/share/icons"
      "/share/pixmaps"
      "/share/mime"
    ];

    # Ensure XDG MIME database is properly updated
    environment.systemPackages = with pkgs; [
      shared-mime-info
      desktop-file-utils
      mpv
    ];

    ${namespace} = {
      theme = {
        stylix.enable = pkgs.stdenv.isLinux;
      };

      security.yubikey.enable = true;
    };

    browsers.chromium.enable = true;

    roles = {
      common.enable = true;
    };

    hardware.${namespace} = {
      audio.enable = true;
      bluetooth.enable = true;
      logitechMouse.enable = true;
      power.enable = true;
      printing.enable = true;
      storage.enable = true;
      zsa.enable = true;
    };

    services = {
      ${namespace} = {
        localsend.enable = true;
        syncthing.enable = true;
      };

      vpn.tailscale.enable = true;
    };
  };
}
