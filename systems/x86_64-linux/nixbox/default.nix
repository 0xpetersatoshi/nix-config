{
  pkgs,
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
    kwallet.enable = true;
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

  networking.hostName = "nixbox";

  boot = {
    # supportedFilesystems = lib.mkForce ["btrfs"];
    kernelPackages = pkgs.linuxPackages_zen;
    # resumeDevice = "/dev/disk/by-label/nixos";
  };

  hardware.drivers = {
    enable = true;
    hasAmdCpu = true;
    hasNvidiaGpu = true;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    # NOTE: stylix override
    # QT_STYLE_OVERRIDE = "kvantum";
  };

  system.stateVersion = "24.11";
}
