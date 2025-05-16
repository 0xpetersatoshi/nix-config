{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.vpn.tailscale;
in {
  options.services.vpn.tailscale = with types; {
    enable = mkBoolOpt false "Whether or not to enable tailscale.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      trayscale
    ];

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };

    # Allow Tailscale traffic
    networking.firewall = {
      trustedInterfaces = ["tailscale0"];

      # Allow incoming connections from Tailscale network
      allowedUDPPorts = [config.services.tailscale.port];
    };
  };
}
