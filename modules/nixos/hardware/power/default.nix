{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.${namespace}.power;
in {
  options.hardware.${namespace}.power = with types; {
    enable = mkBoolOpt false "Enable or disable hardware power support";
  };

  config = mkIf cfg.enable {
    services.upower.enable = true;
  };
}
