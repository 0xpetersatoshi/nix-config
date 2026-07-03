{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  # Shared options for the TrueNAS NFS mounts. `x-systemd.automount` + `noauto` makes each
  # mount lazy and self-healing: rather than a single attempt at boot (which fails and stays
  # failed when the network or the TrueNAS VM isn't ready yet after a host reboot), the mount
  # is (re)attempted on first access and, with `hard`, retries until the server responds.
  # This removes the need to run `nh os switch` by hand to re-mount after a restart.
  nfsMountOpts = extra:
    [
      "nfsvers=4"
      "hard"
      "_netdev"
      "noauto"
      "x-systemd.automount"
      "x-systemd.mount-timeout=30"
      "x-systemd.idle-timeout=0"
    ]
    ++ extra;

  # Mountpoints that Docker containers bind into. Docker must wait for the real NFS mounts
  # before starting so it never binds an empty underlying directory (e.g. traefik ssl-certs).
  nfsMountpoints = [
    "/mnt/appdata"
    "/mnt/media"
    "/mnt/immich"
    "/mnt/syncthing"
    "/mnt/nextcloud"
    "/mnt/isos"
  ];
in {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  # Enable stylix theme
  ${namespace}.theme.stylix = {
    enable = true;
    theme = "tokyo-night-storm";
  };

  # Add dockerhost group to match TrueNAS permissions
  users = {
    users.${config.user.name} = {
      uid = lib.mkForce 568; # Match UID from TrueNAS
      isNormalUser = lib.mkForce false;
      isSystemUser = true;
      extraGroups = ["apps" "render"];
    };

    groups.apps = {
      gid = 568; # Match the GID from TrueNAS
    };
  };

  fileSystems."/mnt/appdata" = {
    device = "10.19.50.2:/mnt/flashpool/appdata";
    fsType = "nfs";
    options = nfsMountOpts ["rsize=131072" "wsize=131072"];
  };

  fileSystems."/mnt/media" = {
    device = "10.19.50.2:/mnt/flashpool/data";
    fsType = "nfs";
    options = nfsMountOpts ["rsize=1048576" "wsize=1048576"];
  };

  fileSystems."/mnt/immich" = {
    device = "10.19.50.2:/mnt/flashpool/media/immich";
    fsType = "nfs";
    options = nfsMountOpts ["rsize=1048576" "wsize=1048576"];
  };

  fileSystems."/mnt/syncthing" = {
    device = "10.19.50.2:/mnt/flashpool/syncthing";
    fsType = "nfs";
    options = nfsMountOpts ["rsize=1048576" "wsize=1048576"];
  };

  fileSystems."/mnt/nextcloud" = {
    device = "10.19.50.2:/mnt/flashpool/nextcloud";
    fsType = "nfs";
    options = nfsMountOpts ["rsize=1048576" "wsize=1048576"];
  };

  fileSystems."/mnt/isos" = {
    device = "10.19.50.2:/mnt/rustpool/isos";
    fsType = "nfs";
    options = nfsMountOpts ["rsize=1048576" "wsize=1048576"];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_7_0;
  };

  environment.systemPackages = with pkgs; [
    lshw
    pciutils
  ];

  hardware = {
    drivers = {
      enable = true;
      hasIntelCpu = true;
      hasIntelGpu = true;
    };

    enableAllFirmware = true;
  };

  networking.hostName = "appbox";
  roles.server.enable = true;

  # Open ports for Docker services running in host mode
  networking.firewall.allowedTCPPorts = [
    2222
    8123
    8096
  ];

  # Generate SSH key for the user if it doesn't exist
  system.activationScripts.generateUserSSHKey = ''
    if [ ! -f /home/${config.user.name}/.ssh/id_ed25519 ]; then
      mkdir -p /home/${config.user.name}/.ssh
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f /home/${config.user.name}/.ssh/id_ed25519 -N ""
      chown -R ${config.user.name}:users /home/${config.user.name}/.ssh
      chmod 700 /home/${config.user.name}/.ssh
      chmod 600 /home/${config.user.name}/.ssh/id_ed25519
      chmod 644 /home/${config.user.name}/.ssh/id_ed25519.pub
    fi
  '';

  services = {
    virtualisation = {
      docker.enable = true;
      podman.enable = false;
    };
  };

  # Hold Docker until every TrueNAS NFS share is actually mounted, so containers bind the
  # real data instead of empty mountpoints (this is what breaks traefik's ssl-certs, and
  # fails the n8n/zitadel file binds, on boot). Accessing each automount triggers the backing
  # mount; the loop then waits for the real nfs mount to appear before letting Docker start.
  #
  # Gate BOTH docker.service and docker.socket: dockerd can be started either by
  # multi-user.target or on-demand via socket activation, and only gating the service lets
  # the socket path start dockerd before the mounts are ready.
  systemd.services.nfs-mounts-ready = {
    description = "Wait for TrueNAS NFS mounts before starting Docker";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    before = ["docker.service" "docker.socket"];
    requiredBy = ["docker.service" "docker.socket"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # TrueNAS (a sibling VM) can take minutes to serve NFS after a host reboot; never let
      # the default 90s start timeout fail the gate and take Docker's dependency down with it.
      TimeoutStartSec = "infinity";
    };
    script = ''
      for m in ${lib.concatStringsSep " " nfsMountpoints}; do
        until ${pkgs.util-linux}/bin/findmnt --types nfs,nfs4 "$m" > /dev/null 2>&1; do
          ${pkgs.coreutils}/bin/ls "$m" > /dev/null 2>&1 || true
          ${pkgs.coreutils}/bin/sleep 2
        done
      done
    '';
  };

  # Belt-and-suspenders: express the mount dependency directly on dockerd too, so the ordering
  # holds even if something triggers the daemon outside the gate.
  systemd.services.docker.unitConfig.RequiresMountsFor = nfsMountpoints;

  system = {
    boot = {
      nixConfigurationLimit = 5;
      secureBoot = false;
    };

    stateVersion = "25.05";
  };
}
