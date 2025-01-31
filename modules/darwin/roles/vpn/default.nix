{
  lib,
  config,
  namespace,
  ...
}: let
  cfg = config.roles.vpn;
in {
  options.roles.vpn = {
    enable = lib.mkEnableOption "Enable vpn guis";
  };

  config = lib.mkIf cfg.enable {
    programs.guis.vpn.enable = true;
    services.${namespace}.tailscale.enable = true;
  };
}
