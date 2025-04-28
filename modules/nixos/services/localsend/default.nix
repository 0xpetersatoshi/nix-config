{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.${namespace}.localsend;
in {
  options.services.${namespace}.localsend = {
    enable = mkEnableOption "Enable the localsend service";
  };

  config = mkIf cfg.enable {
    programs.localsend = {
      enable = true;
    };
  };
}
