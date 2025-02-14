{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.power;
in {
  options.hardware.power = with types; {
    enable = mkBoolOpt false "Enable or disable hardware power support";
  };

  config = mkIf cfg.enable {
    services.upower.enable = true;
  };
}
