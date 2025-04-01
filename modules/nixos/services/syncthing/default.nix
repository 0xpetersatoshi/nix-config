{
  config,
  lib,
  namespace,
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
        openDefaultPorts = true;
      };
    };
  };
}
