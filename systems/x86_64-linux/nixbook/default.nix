{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  security = {
    _1password-browser-integration.enable = true;
    _1password-gui.enable = true;
    kwalletAutoUnlock.enable = true;
  };

  services = {
    virtualisation = {
      podman.enable = true;
    };
    thermald.enable = true;
    tlp.enable = true;
  };

  powerManagement.enable = true;

  roles = {
    desktop = {
      enable = true;
      addons = {
        hyprland.enable = true;
        kde.enable = true;
      };
    };
  };

  networking.hostName = "nixbook";

  boot = {
    # supportedFilesystems = lib.mkForce ["btrfs"];
    kernelPackages = pkgs.unstable.linuxPackages_zen;
    # resumeDevice = "/dev/disk/by-label/nixos";

    # TODO: add iGPU device id
    # kernelParams = ["i915.force_probe=<device ID>"];
    # kernelParams = ["intel_idle.max_cstate=1"];

    # Additional power saving features
    kernelParams = [
      "i915.enable_psr=1" # Panel Self Refresh
      "i915.enable_fbc=1" # Framebuffer Compression
      "i915.enable_guc=2" # GuC/HuC firmware loading
    ];

    initrd.luks.devices = {
      "nixos-enc" = {
        device = "/dev/disk/by-partlabel/nixos";
        allowDiscards = true;
        preLVM = true;
      };
    };
  };

  hardware = {
    drivers = {
      enable = true;
      hasIntelCpu = true;
      hasIntelGpu = true;
    };
    enableAllFirmware = true;
  };

  styles.stylix.wallpaperPath = ../../../wallpaper/standard/astronaut-3-2912x1632.png;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Use intel-media-driver
    MOZ_X11_EGL = "1"; # Enable hardware acceleration in Firefox
    VDPAU_DRIVER = "va_gl"; # VDPAU through VAAPI
    XDG_SESSION_TYPE = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  system.stateVersion = "24.11";
}
