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

    # Only specify the essential modules
    initrd.kernelModules = [
      # Just the core modules - let the system figure out dependencies
      "snd-sof-pci-intel-lnl" # Lunar Lake specific module
    ];

    kernelModules = [
      "snd-sof-pci-intel-lnl" # Lunar Lake specific module
      "btusb" # Bluetooth support
    ];

    # Additional power saving features
    kernelParams = [
      "i915.enable_psr=1" # Panel Self Refresh
      "i915.enable_fbc=1" # Framebuffer Compression
      "i915.enable_guc=3" # GuC/HuC firmware loading
      "i915.force_probe=all"

      # Audio-specific parameters
      "snd_intel_dspcfg.dsp_driver=1"
    ];

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

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Use intel-media-driver
    MOZ_X11_EGL = "1"; # Enable hardware acceleration in Firefox
    VDPAU_DRIVER = "va_gl"; # VDPAU through VAAPI
    XDG_SESSION_TYPE = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  system.stateVersion = "24.11";
}
