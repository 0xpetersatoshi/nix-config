{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.vpn.openvpn;
in {
  options.services.vpn.openvpn = with types; {
    enable = mkBoolOpt false "Whether or not to enable openvpn.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      openvpn3
    ];
  };
}
