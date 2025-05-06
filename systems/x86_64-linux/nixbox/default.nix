{pkgs, ...}: {
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
    initrd.kernelModules = ["nvidia"];
  };

  environment.sessionVariables = {
    # Configure VAAPI and VDPAU drivers for video acceleration
    LIBVA_DRIVER_NAME = "nvidia";
    VDPAU_DRIVER = "nvidia";

    # Set primary GPU for rendering
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";

    # Use proper Chromium flags instead
    CHROMIUM_FLAGS = "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder --disable-features=UseChromeOSDirectVideoDecoder --use-gl=egl --ozone-platform=wayland --ignore-gpu-blocklist";
  };

  hardware = {
    drivers = {
      enable = true;
      hasAmdCpu = true;
      hasNvidiaGpu = true;
    };

    enableAllFirmware = true;
  };

  networking.hostName = "nixbox";

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

  security = {
    _1password-browser-integration.enable = true;
    _1password-gui.enable = true;
  };

  services = {
    virtualisation = {
      docker.enable = true;
      podman.enable = false;
    };

    xserver.videoDrivers = ["nvidia" "modeset"];
  };

  styles.stylix = {
    theme = "tokyo-night-storm";
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
