{
  lib,
  config,
  ...
}: let
  cfg = config.roles.security;
in {
  options.roles.security = {
    enable = lib.mkEnableOption "Enable security guis";
  };

  config = lib.mkIf cfg.enable {
    programs.guis.security.enable = true;
  };
}
