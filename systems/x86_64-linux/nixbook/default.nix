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

  networking.hostName = "nixbook";

  boot = {
    # supportedFilesystems = lib.mkForce ["btrfs"];
    kernelPackages = pkgs.unstable.linuxPackages_zen;
    # resumeDevice = "/dev/disk/by-label/nixos";
  };

  hardware = {
    drivers = {
      enable = true;
      hasIntelCpu = true;
    };
  };

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  system.stateVersion = "24.11";
}
