{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  # Add dockerhost group to match TrueNAS permissions
  users = {
    users.${config.user.name} = {
      extraGroups = ["apps"];
    };

    groups.apps = {
      gid = 568; # Match the GID from TrueNAS
    };
  };

  fileSystems."/mnt/appdata" = {
    device = "10.19.50.2:/mnt/flashpool/appdata";
    fsType = "nfs";
    options = ["nfsvers=4" "hard" "rsize=131072" "wsize=131072"];
  };

  fileSystems."/mnt/media" = {
    device = "10.19.50.2:/mnt/flashpool/data";
    fsType = "nfs";
    options = ["nfsvers=4" "hard" "rsize=1048576" "wsize=1048576"];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware = {
    drivers = {
      enable = true;
      hasIntelCpu = true;
    };

    enableAllFirmware = true;
  };

  networking.hostName = "appbox";
  roles.server.enable = true;

  services = {
    virtualisation = {
      docker.enable = true;
      podman.enable = false;
    };
  };

  system = {
    boot = {
      nixConfigurationLimit = 5;
      secureBoot = false;
    };

    stateVersion = "25.05";
  };
}
