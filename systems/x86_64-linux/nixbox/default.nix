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
    ${namespace} = {
      udev.web3.enable = true;
      audio.hdmiKeepalive = true;
    };

    drivers = {
      enable = true;
      hasAmdCpu = true;
      hasAmdGpu = true;
    };

    suspend = {
      enable = true;
      hasAmdCpu = true;
      # Mellanox ConnectX-3 replaced with an Intel X550 (10Gtek) — the mlx4
      # link-flap workarounds are no longer needed
      hasMlx4Nic = false;
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
        kwallet.enable = true;
        sddm.enable = true;
        nautilus.enable = true;
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

    vpn.openvpn.enable = true;

    xserver.videoDrivers = ["amdgpu" "modeset"];
  };

  system = {
    boot = {
      nixConfigurationLimit = 5;
      secureBoot = true;
      luksDevicePaths = ["/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S59CNM0R856340J-part2"];
      secureBootKeysPath = "/var/lib/sbctl";
    };
    stateVersion = "24.11";
  };
}
