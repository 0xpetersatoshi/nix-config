{
  pkgs,
  namespace,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  services.xserver.videoDrivers = ["amdgpu" "nvidia" "modeset"];

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
    gaming.enable = true;
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
      hasAmdGpu = true;
      hasNvidiaGpu = true;
      hasIntegratedGpu = true;
    };

    nvidia.prime = {
      amdgpuBusId = "PCI:11:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    enableAllFirmware = true;

    suspend = {
      enable = false;
      hasAmdCpu = true;
      hasNvidiaGpu = true;
    };
  };

  environment.sessionVariables = {
    # Use AMD for video acceleration
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";

    # For Chromium-based browsers
    DISABLE_ACCELERATED_VIDEO_DECODE = "0";
    DISABLE_ACCELERATED_VIDEO_ENCODE = "0";

    # Set primary GPU for rendering
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # For NVIDIA as primary 3D renderer
    GBM_BACKEND = "nvidia-drm";

    # Use proper Chromium flags instead
    CHROMIUM_FLAGS = "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder --disable-features=UseChromeOSDirectVideoDecoder --use-gl=egl --ozone-platform=wayland --ignore-gpu-blocklist";
  };

  system = {
    boot.nixConfigurationLimit = 5;
    stateVersion = "24.11";
  };
}
