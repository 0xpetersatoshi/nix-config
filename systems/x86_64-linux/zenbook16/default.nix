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
      # https://community.frame.work/t/fedora-kde-becomes-suddenly-slow/58459
      # https://gitlab.freedesktop.org/drm/amd/-/issues/3647
      "amdgpu.dcdebugmask=0x10"
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
      useUnstableMesa = true;
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

  # hardware.${namespace} = {
  #   asus = {
  #     enable = true;
  #   };
  #
  #   bluetooth.settings = {
  #     Experimental = true;
  #     FastConnectable = true;
  #     JustWorksRepairing = "always";
  #     MultiProfile = "multiple";
  #   };
  # };

  styles.stylix = {
    wallpaperPath = ../../../wallpaper/standard/astronaut-4-2912x1632.png;
    theme = "tokyo-night-storm";
  };

  system = {
    boot.nixConfigurationLimit = 5;
    stateVersion = "24.11";
  };
}
