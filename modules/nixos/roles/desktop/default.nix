{
  lib,
  config,
  namespace,
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
    environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];

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
      zsa.enable = true;
    };

    user = {
      name = "peter";
      initialPassword = "1";
    };
  };
}
