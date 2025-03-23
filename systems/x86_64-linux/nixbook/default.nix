{pkgs, ...}: let
  # Fix sound
  custom-alsa-ucm-conf = pkgs.fetchFromGitHub {
    owner = "alsa-project";
    repo = "alsa-ucm-conf";
    rev = "f293b3149b8b370fed70eb83025410ddaee8a9cf";
    hash = "sha256-SEAizUiMbSN7iEsHoiDEJkBFdaVPyi/t2YN7Jao22iw=";
  };
in {
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
    keyboard.kanata = {
      enable = true;
      configFile = ../../../dotfiles/kanata/linux.config.kbd;
    };
    thermald.enable = true;
    # conflicts with pkgs.power-profiles-daemon used by hyprpanel
    # tlp.enable = true;
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
    kernelPackages = pkgs.unstable.linuxPackages_latest;

    initrd.luks.devices = {
      "nixos-enc" = {
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
    input-devices.touchpad.enable = true;

    bluetooth.package = pkgs.unstable.bluez;

    firmware = with pkgs; [
      unstable.sof-firmware
      unstable.linux-firmware
    ];
  };

  styles.stylix.wallpaperPath = ../../../wallpaper/standard/astronaut-3-2912x1632.png;

  system = {
    stateVersion = "24.11";
  };

  environment = {
    sessionVariables = {
      ALSA_CONFIG_UCM2 = "${custom-alsa-ucm-conf}/ucm2";
      LIBVA_DRIVER_NAME = "iHD"; # Use intel-media-driver
      MOZ_X11_EGL = "1"; # Enable hardware acceleration in Firefox
      VDPAU_DRIVER = "va_gl"; # VDPAU through VAAPI
      XDG_SESSION_TYPE = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}
