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

  # Custom Intel Bluetooth firmware package
  custom-intel-bt-firmware = pkgs.stdenv.mkDerivation {
    name = "custom-intel-bt-firmware";

    src = pkgs.fetchgit {
      url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
      rev = "47bc8a2407426274d099607d5af419cb616d9209"; # Specific commit with the firmware
      hash = "sha256-V581DtceoFuY/GP4eTcq+aACUd+WY+SdtuDUX8UHB+4=";
    };

    installPhase = ''
      mkdir -p $out/lib/firmware/intel
      cp intel/ibt-0190-0291-usb.sfi $out/lib/firmware/intel/
      cp intel/ibt-0190-0291-usb.ddc $out/lib/firmware/intel/
      cp intel/ibt-0190-0291-pci.sfi $out/lib/firmware/intel/
      cp intel/ibt-0190-0291-pci.ddc $out/lib/firmware/intel/
    '';
  };
in {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
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

  networking.hostName = "nixbook";

  boot = {
    kernelPackages = pkgs.unstable.linuxPackages_latest;

    loader.efi.efiSysMountPoint = "/boot/efi"; # Mount point for the EFI partition

    initrd.luks.devices = {
      "nixos-root" = {
        device = "/dev/disk/by-uuid/6ff16ca1-0e28-4afc-b61b-e3bcc78b8ec6";
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
      custom-intel-bt-firmware
    ];
  };

  styles.stylix = {
    wallpaperPath = ../../../wallpaper/standard/astronaut-3-2912x1632.png;
    theme = "tokyo-night-storm";
  };

  system = {
    stateVersion = "24.11";
  };

  environment = {
    sessionVariables = {
      ALSA_CONFIG_UCM2 = "${custom-alsa-ucm-conf}/ucm2";
      LIBVA_DRIVER_NAME = "iHD"; # Use intel-media-driver
      WLR_DRM_DEVICES = "/dev/dri/by-path/pci-0000:00:02.0-card";
      MOZ_X11_EGL = "1"; # Enable hardware acceleration in Firefox
      VDPAU_DRIVER = "va_gl"; # VDPAU through VAAPI
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}
