{
  lib,
  config,
  ...
}: let
  cfg = config.roles.development;
in {
  options.roles.development = {
    enable = lib.mkEnableOption "Enable development guis";
  };

  config = lib.mkIf cfg.enable {
    programs.guis.development.enable = true;
  };
}
