{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  fileSystems."/mnt/appdata" = {
    device = "10.19.50.2:/appdata";
    fsType = "nfs";
  };

  fileSystems."/mnt/media" = {
    device = "10.19.50.2:/data";
    fsType = "nfs";
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
