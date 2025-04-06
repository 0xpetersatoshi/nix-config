{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.${namespace}.syncthing;
in {
  options.services.${namespace}.syncthing = {
    enable = mkEnableOption "Enable the syncthing service";
  };

  config = mkIf cfg.enable {
    services = {
      syncthing = {
        enable = true;
        user = config.user.name;
        group = "users";
        dataDir = "/home/${config.user.name}";
        configDir = "/home/${config.user.name}/.config/syncthing";
        openDefaultPorts = true;
        overrideDevices = false;
        overrideFolders = false;
      };
    };

    environment.systemPackages = with pkgs; [
      syncthingtray
    ];
  };
}
