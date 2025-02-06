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
