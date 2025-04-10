{
  pkgs,
  namespace,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  services.xserver.videoDrivers = ["nvidia"];

  security = {
    _1password-browser-integration.enable = true;
    _1password-gui.enable = true;
  };

  services = {
    virtualisation = {
      docker.enable = true;
      podman.enable = false;
    };

    ${namespace} = {
      syncthing.enable = true;
    };
  };

  roles = {
    desktop = {
      enable = true;
      addons = {
        hyprland.enable = true;
        kde.enable = true;
      };
    };
  };

  styles.stylix = {
    wallpaperPath = ../../../wallpaper/ultrawide/sci_fi_architecture_building_beach-wallpaper-3440x1440.jpg;
    theme = "tokyo-night-storm";
  };

  networking.hostName = "nixbox";

  boot = {
    # supportedFilesystems = lib.mkForce ["btrfs"];
    kernelPackages = pkgs.unstable.linuxPackages_zen;
    # resumeDevice = "/dev/disk/by-label/nixos";
  };

  hardware = {
    drivers = {
      enable = true;
      hasAmdCpu = true;
      hasNvidiaGpu = true;
    };

    enableAllFirmware = true;

    suspend = {
      enable = true;
      hasAmdCpu = true;
      hasNvidiaGpu = true;
    };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    # NOTE: stylix override
    # QT_STYLE_OVERRIDE = "kvantum";
  };

  system.stateVersion = "24.11";
}
