{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.${namespace}.flatpak;
in {
  options.services.${namespace}.flatpak = {
    enable = mkEnableOption "Enable the flatpak service";
  };

  config = mkIf cfg.enable {
    services = {
      flatpak = {
        enable = true;
      };
    };
  };
}
