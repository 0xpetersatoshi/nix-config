{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.${namespace}.storage;
in {
  options.hardware.${namespace}.storage = with types; {
    enable = mkBoolOpt false "Enable or disable hardware storage support";
  };

  config = mkIf cfg.enable {
    services.udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
  };
}
