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
  updateResolved = pkgs.update-systemd-resolved;
in {
  options.services.vpn.openvpn = with types; {
    enable = mkBoolOpt false "Whether or not to enable openvpn.";

    name = mkOpt str "client" "Name for the OpenVPN connection (used in systemd service name).";

    configFile = mkOpt path "/home/${config.user.name}/.openvpn/client.ovpn" "Path to the .ovpn configuration file on disk.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      openvpn
    ];

    services.openvpn.servers.${cfg.name} = {
      autoStart = false;
      config = ''
        config ${cfg.configFile}

        # Integrate with systemd-resolved for DNS management.
        # This ensures VPN-pushed DNS servers are registered with resolved
        # and cleaned up when the tunnel goes down.
        script-security 2
        setenv PATH /usr/bin:/bin:/usr/sbin:/sbin:${updateResolved}/libexec/openvpn
        up ${updateResolved}/libexec/openvpn/update-systemd-resolved
        up-restart
        down ${updateResolved}/libexec/openvpn/update-systemd-resolved
        down-pre
      '';
    };
  };
}
