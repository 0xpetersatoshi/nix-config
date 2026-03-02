{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.networking;
  networkName =
    if cfg.wireless
    then "40-wireless"
    else "40-wired";
in {
  options.hardware.networking = with types; {
    enable = mkBoolOpt false "Enable networking";
    wireless = mkBoolOpt false "Enable wireless networking (iwd)";
  };

  config = mkIf cfg.enable {
    networking = {
      # Disable NixOS auto-generated per-interface network configs (e.g. "40-enp10s0.network").
      # These auto-configs don't set UseDomains = true, which means DHCP-provided search domains
      # (like "home.mydomain.xyz" from OPNsense) are silently ignored by systemd-networkd.
      # Instead, we define our own type-based network configs below that handle DHCP properly.
      useDHCP = lib.mkForce false;

      # Use systemd-networkd for wired connections. When wireless is enabled, iwd handles
      # network configuration directly via EnableNetworkConfiguration.
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

    # Only require one interface to be online for the system to consider
    # networking ready. Without this, systemd-networkd-wait-online blocks
    # on ALL matched ethernet interfaces (including disconnected ones like
    # enp15s0), causing activation to hang indefinitely.
    systemd.network.wait-online.anyInterface = true;

    # Define a single network config that matches by interface type rather than by name.
    # This makes the config portable across machines — "ether" matches any wired NIC
    # (enp10s0, enp13s0, etc.) and "wlan" matches any wireless NIC, regardless of what
    # the kernel names them on a given machine.
    systemd.network.networks.${networkName} = {
      matchConfig = {
        Type =
          if cfg.wireless
          then "wlan"
          else "ether";
        # Match only physical NICs (i.e. "enp15s0") and exclude docker interfaces
        Name =
          if cfg.wireless
          then "wl*"
          else "en*";
      };
      networkConfig.DHCP = "yes";

      # Accept DNS search domains from DHCP (OPNsense pushes "home.mydomain.xyz").
      # systemd-networkd defaults UseDomains to false, which causes the search domain
      # to be missing from resolvectl — breaking short-name resolution (e.g. "ping opnsense"
      # won't expand to "ping opnsense.home.mydomain.xyz" without this).
      dhcpV4Config.UseDomains = true;

      # For wired interfaces, require a routable address before considering the network online.
      # This prevents systemd-networkd-wait-online from hanging on interfaces that are
      # physically connected but haven't obtained a lease yet.
      linkConfig.RequiredForOnline = mkIf (!cfg.wireless) "routable";
    };
  };
}
