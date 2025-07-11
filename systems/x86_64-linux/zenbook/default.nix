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

    keyboard.kanata = {
      enable = true;
      configFile = ../../../dotfiles/kanata/linux.config.kbd;
    };
    thermald.enable = true;
    # conflicts with pkgs.power-profiles-daemon used by hyprpanel
    # tlp.enable = true;

    ${namespace} = {
      keybase.enable = true;
    };
  };

  powerManagement.enable = true;

  roles = {
    desktop = {
      enable = true;
      addons = {
        appimage.enable = true;
        hyprland.enable = true;
        kde.enable = true;
      };
    };

    gaming.enable = true;
  };

  networking.hostName = "zenbook";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
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

    bluetooth.package = pkgs.bluez;

    firmware = with pkgs; [
      sof-firmware
      linux-firmware
    ];
  };

  hardware.${namespace} = {
    asus = {
      enable = true;
    };

    bluetooth.settings = {
      Experimental = true;
      FastConnectable = true;
      JustWorksRepairing = "always";
      MultiProfile = "multiple";
    };
  };

  system = {
    boot = {
      secureBoot = true;
      luksDevicePaths = ["/dev/nvme0n1p2"];
      secureBootKeysPath = "/var/lib/sbctl";
      nixConfigurationLimit = 5;
    };

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
