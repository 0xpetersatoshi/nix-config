{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.networking;
in {
  options.hardware.networking = with types; {
    enable = mkBoolOpt false "Enable networking";
    wireless = mkBoolOpt false "Enable wireless networking (iwd)";
  };

  config = mkIf cfg.enable {
    networking = {
      useNetworkd = !cfg.wireless;

      firewall = {
        enable = true;

        # allow SMB traffic
        allowedTCPPorts = [139 445];

        # allow NetBIOS name resolution
        allowedUDPPorts = [137 138];

        # allow samba discovery of machines and shares
        extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
      };

      wireless.iwd = mkIf cfg.wireless {
        enable = true;
        settings = {
          General = {
            EnableNetworkConfiguration = true;
          };
          Network = {
            NameResolvingService = "systemd";
          };
          Settings = {
            AutoConnect = true;
          };
        };
      };
    };
  };
}
