{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hardware.${namespace}.printing;
in {
  options.hardware.${namespace}.printing = {
    enable = mkEnableOption "Enable printing service and packages";
  };

  config = mkIf cfg.enable {
    services.printing.enable = true;

    networking.firewall = {
      allowedUDPPorts = [631];
      allowedTCPPorts = [631];
    };

    environment.systemPackages = with pkgs; [
      hplip
      system-config-printer
    ];
  };
}
