{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:
with lib; let
  cfg = config.roles.server;
in {
  options.roles.server = {
    enable = mkEnableOption "Enable server configuration";
  };

  config = mkIf cfg.enable {
    roles = {
      common.enable = true;
    };

    services = {
      ${namespace} = {
        avahi.enable = true;
        nfs.enable = true;
        ssh.enable = true;
      };

      vpn.tailscale.enable = true;

      getty.autologinUser = "peter";
      # openiscsi = {
      #   enable = true;
      #   name = "<some-name>";
      # };
    };

    environment = {
      systemPackages = with pkgs; [
        btop
        curl
        dnsutils
        dysk
        fzf
        ghostty # to fix ghostty terminfo issue when ssh'ing
        git
        jq
        neovim
        nettools
        openiscsi
        ripgrep
        vim
        wget
      ];
      # Print the URL instead on servers
      variables.BROWSER = "echo";
    };
    # // lib.optionalAttrs (lib.versionAtLeast (lib.versions.majorMinor lib.version) "24.05") {
    #   # Don't install the /lib/ld-linux.so.2 and /lib64/ld-linux-x86-64.so.2
    #   # stubs. Server users should know what they are doing.
    #   stub-ld.enable = lib.mkDefault false;
    # };

    security = {
      sudo = {
        wheelNeedsPassword = false;
        # Only allow members of the wheel group to execute sudo by setting the executable’s permissions accordingly. This prevents users that are not members of wheel from exploiting vulnerabilities in sudo such as CVE-2021-3156.
        execWheelOnly = true;
        # Don't lecture the user. Less mutable state.
        extraConfig = ''
          Defaults lecture = never
        '';
      };
    };

    # Notice this also disables --help for some commands such as nixos-rebuild
    # documentation = {
    #   enable = lib.mkDefault false;
    #   info.enable = lib.mkDefault false;
    #   man.enable = lib.mkDefault false;
    #   nixos.enable = lib.mkDefault false;
    # };

    # No need for fonts on a server
    fonts.fontconfig.enable = lib.mkDefault false;

    # UTC everywhere!
    # time.timeZone = lib.mkDefault "UTC";

    # No mutable users by default
    users.mutableUsers = false;

    systemd = {
      services.NetworkManager-wait-online.enable = false;
      network.wait-online.enable = false;
      tmpfiles.rules = [
        "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
      ];

      # Given that our systems are headless, emergency mode is useless.
      # We prefer the system to attempt to continue booting so
      # that we can hopefully still access it remotely.
      enableEmergencyMode = false;

      # For more detail, see:
      #   https://0pointer.de/blog/projects/watchdog.html
      watchdog = {
        # systemd will send a signal to the hardware watchdog at half
        # the interval defined here, so every 10s.
        # If the hardware watchdog does not get a signal for 20s,
        # it will forcefully reboot the system.
        runtimeTime = "20s";
        # Forcefully reboot if the final stage of the reboot
        # hangs without progress for more than 30s.
        # For more info, see:
        #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
        rebootTime = "30s";
      };
    };

    # use TCP BBR has significantly increased throughput and reduced latency for connections
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };
}
