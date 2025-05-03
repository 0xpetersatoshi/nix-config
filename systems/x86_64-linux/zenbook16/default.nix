{
  pkgs,
  namespace,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.unstable.linuxPackages_latest;
    kernelParams = [
      # There seems to be an issue with panel self-refresh (PSR) that
      # causes hangs for users.
      #
      # Disables PSR2-SU due to issue that causes random freezing/hanging
      # More info can be found here: https://wiki.archlinux.org/title/ASUS_Zenbook_UM5606#Panel_Self_Refresh
      "amdgpu.dcdebugmask=0x200"
    ];
    loader.efi.efiSysMountPoint = "/boot";
  };

  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
      MOZ_X11_EGL = "1"; # Enable hardware acceleration in Firefox
    };
  };

  hardware = {
    drivers = {
      enable = true;
      hasAmdCpu = true;
      hasAmdGpu = true;
      useUnstableMesa = false;
      vulkanEnabled = true;
    };
    enableAllFirmware = true;
    input-devices.touchpad.enable = true;

    bluetooth.package = pkgs.unstable.bluez;

    firmware = with pkgs; [
      unstable.sof-firmware
      unstable.linux-firmware
    ];
  };

  networking.hostName = "zenbook16";

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

  security = {
    _1password-browser-integration.enable = true;
    _1password-gui.enable = true;
  };

  services = {
    xserver.videoDrivers = ["amdgpu"];
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

  styles.stylix = {
    wallpaperPath = ../../../wallpaper/standard/astronaut-4-2912x1632.png;
    theme = "tokyo-night-storm";
  };

  system = {
    boot = {
      nixConfigurationLimit = 5;
      secureBoot = true;
    };

    stateVersion = "24.11";
  };

  systemd.user.services.plasma-kwin_wayland = {
    environment = {
      KWIN_DRM_DISABLE_TRIPLE_BUFFERING = "1";
    };
  };
}
