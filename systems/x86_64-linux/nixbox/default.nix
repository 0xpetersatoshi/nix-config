{
  pkgs,
  namespace,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  igloo = {
    theme.stylix = {
      enable = true;
      theme = "tokyo-night-storm";
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
  };

  hardware = {
    ${namespace}.udev.web3.enable = true;

    drivers = {
      enable = true;
      hasAmdCpu = true;
      hasAmdGpu = true;
    };

    enableAllFirmware = true;

    firmware = with pkgs; [
      linux-firmware
    ];
  };

  networking.hostName = "nixbox";

  roles = {
    development.enable = true;
    desktop = {
      enable = true;
      addons = {
        hyprland.enable = true;
        kde.enable = true;
      };
    };
    gaming.enable = true;
  };

  security = {
    _1password-browser-integration.enable = true;
    _1password-gui.enable = true;

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

    xserver.videoDrivers = ["amdgpu" "modeset"];
  };

  system = {
    boot = {
      nixConfigurationLimit = 5;
      secureBoot = true;
      luksDevicePaths = ["/dev/nvme1n1p2"];
      secureBootKeysPath = "/var/lib/sbctl";
    };
    stateVersion = "24.11";
  };
}
