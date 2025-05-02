{
  config,
  lib,
  namespace,
  ...
}:
with lib; let
  cfg = config.hardware.${namespace}.firmware;
in {
  options.hardware.${namespace}.firmware = {
    enable = mkEnableOption "Enable firmware service and packages";
  };

  config = mkIf cfg.enable {
    services.fwupd.enable = true;
  };
}
