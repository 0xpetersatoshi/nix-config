{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
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
    kernelParams = ["i915.force_probe=<device ID>"];
    # kernelParams = ["intel_idle.max_cstate=1"];
  };

  hardware = {
    drivers = {
      enable = true;
      hasIntelCpu = true;
    };
  };

  styles.stylix.wallpaperPath = ../../../wallpaper/standard/astronaut-3-2912x1632.png;

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  system.stateVersion = "24.11";
}
