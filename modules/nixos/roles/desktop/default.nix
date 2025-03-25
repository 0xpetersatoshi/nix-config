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
    ];

    # Make sure the MIME database is properly updated
    system.activationScripts.updateMimeDatabase = {
      text = ''
        echo "Updating MIME database..."
        ${pkgs.shared-mime-info}/bin/update-mime-database /run/current-system/sw/share/mime
      '';
      deps = [];
    };

    roles = {
      common.enable = true;

      # desktop.addons = {
      #   nautilus.enable = true;
      # };
    };

    hardware = {
      audio.enable = true;
      bluetooth.enable = true;
      logitechMouse.enable = true;
      power.enable = true;
      storage.enable = true;
      zsa.enable = true;
    };

    user = {
      name = "peter";
      initialPassword = "1";
    };
  };
}
