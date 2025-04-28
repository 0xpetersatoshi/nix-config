{
  pkgs,
  namespace,
  ...
}: let
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
  ];

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
      localsend.enable = true;
      syncthing.enable = true;
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

    gaming.enable = true;
  };

  networking.hostName = "zenbook";

  boot = {
    kernelPackages = pkgs.unstable.linuxPackages_latest;
    loader.efi.efiSysMountPoint = "/boot";
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

  styles.stylix = {
    wallpaperPath = ../../../wallpaper/standard/astronaut-3-2912x1632.png;
    theme = "tokyo-night-storm";
  };

  system = {
    boot.nixConfigurationLimit = 5;
    stateVersion = "24.11";
  };

  environment = {
    sessionVariables = {
      ALSA_CONFIG_UCM2 = "${custom-alsa-ucm-conf}/ucm2";
      ANV_VIDEO_DECODE = "1";
      LIBVA_DRIVER_NAME = "iHD"; # Use intel-media-driver
      VDPAU_DRIVER = "va_gl"; # VDPAU through VAAPI
      MOZ_X11_EGL = "1"; # Enable hardware acceleration in Firefox
    };
  };
}
