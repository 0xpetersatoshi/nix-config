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
      # Let this user drive tailscaled's LocalAPI without sudo, so desktop
      # frontends (DankMaterialShell's native Tailscale widget, trayscale)
      # can query status and toggle the connection. Mirrors Omarchy's
      # `tailscale set --operator=$USER`.
      extraSetFlags = ["--operator=${config.user.name}"];
    };

    # Allow Tailscale traffic
    networking.firewall = {
      trustedInterfaces = ["tailscale0"];

      # Allow incoming connections from Tailscale network
      allowedUDPPorts = [config.services.tailscale.port];
    };
  };
}
