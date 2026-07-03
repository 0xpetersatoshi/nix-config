{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  # Shared options for the TrueNAS NFS mounts. Plain `_netdev` mounts (ordered after the
  # network) with `nofail` so a boot-time race with the TrueNAS VM doesn't fail remote-fs.target
  # or block boot. The retry-until-mounted behaviour lives in the nfs-mounts-ready gate below,
  # which is also what holds Docker back until the real NFS is present. (We deliberately do NOT
  # use x-systemd.automount: converting an already-mounted path to autofs breaks live
  # `nh os switch` activation, and the autofs indirection races Docker's bind mounts.)
  nfsMountOpts = extra:
    [
      "nfsvers=4"
      "hard"
      "_netdev"
      "nofail"
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
  # fails the n8n/zitadel file binds, on boot). The loop actively (re)starts each mount unit
  # until the real NFS mount appears — this is also the retry mechanism for a slow/late
  # TrueNAS after a host reboot, so we don't need automount.
  #
  # Gate docker.service only — NOT docker.socket. docker.socket lives in basic.target, and a
  # unit ordered After=network-online.target (which comes after basic.target) can't run before
  # it without creating an ordering cycle. That's fine: the socket may listen early, but dockerd
  # only starts via docker.service, which is gated — a queued connection just waits for it.
  systemd.services.nfs-mounts-ready = {
    description = "Wait for TrueNAS NFS mounts before starting Docker";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    before = ["docker.service"];
    requiredBy = ["docker.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # TrueNAS (a sibling VM) can take minutes to serve NFS after a host reboot; never let
      # the default 90s start timeout fail the gate and take Docker's dependency down with it.
      TimeoutStartSec = "infinity";
    };
    script = ''
      for m in ${lib.concatStringsSep " " nfsMountpoints}; do
        unit="$(${pkgs.systemd}/bin/systemd-escape -p --suffix=mount "$m")"
        until ${pkgs.util-linux}/bin/findmnt --types nfs,nfs4 "$m" > /dev/null 2>&1; do
          ${pkgs.systemd}/bin/systemctl start "$unit" > /dev/null 2>&1 || true
          ${pkgs.coreutils}/bin/sleep 2
        done
      done
    '';
  };

  system = {
    boot = {
      nixConfigurationLimit = 5;
      secureBoot = false;
    };

    stateVersion = "25.05";
  };
}
