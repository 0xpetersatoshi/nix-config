{
  lib,
  config,
  ...
}: let
  cfg = config.roles.social;
in {
  options.roles.social = {
    enable = lib.mkEnableOption "Enable social guis";
  };

  config = lib.mkIf cfg.enable {
    programs.guis.social.enable = true;
  };
}
