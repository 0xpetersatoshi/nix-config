{
  pkgs,
  namespace,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages;
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

  security = {
    ${namespace} = {
      sops.enable = true;
    };
  };

  services = {
    ${namespace} = {
      samba.enable = true;
    };

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
