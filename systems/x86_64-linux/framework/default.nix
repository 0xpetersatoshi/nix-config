{
  inputs,
  pkgs,
  namespace,
  ...
}: {
  imports = [
    # Framework hardware quirks: fwupd, fprintd, power tuning, ectool,
    # udev rules, and the >= 6.17 kernel floor for Panther Lake
    inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
    # Copied from zenbook: the NVMe drive (filesystems, LUKS container,
    # UUIDs) was transplanted from it. Regenerate on the Framework with
    # `nixos-generate-config` if module detection ever differs.
    ./hardware-configuration.nix
  ];

  security = {
    _1password-browser-integration.enable = true;
    _1password-gui.enable = true;

    ${namespace} = {
      sops.enable = true;
    };
  };

  ${namespace}.security.fingerprint.enable = true;

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
    # nixos-hardware's laptop profile enables TLP unless power-profiles-daemon
    # is on; ppd is what the dms bar talks to, so keep it explicit here
    power-profiles-daemon.enable = true;

    ${namespace} = {
      keybase.enable = true;
      samba.enable = true;
    };
  };

  roles = {
    development.enable = true;
    desktop = {
      enable = true;
      addons = {
        appimage.enable = true;
        hyprland.enable = true;
        kde.enable = true;
        nautilus.enable = true;
      };
    };

    gaming.enable = true;
  };

  networking.hostName = "framework";
  hardware.networking.wireless = true;

  boot = {
    # Panther Lake (CPU + Xe3 iGPU) needs >= 6.17
    kernelPackages = pkgs.linuxPackages_latest;
    loader.efi.efiSysMountPoint = "/boot";
  };

  hardware = {
    # nixos-hardware's Intel GPU module defaults to i915 + both VAAPI
    # drivers; Panther Lake is xe-only with the iHD media driver
    intelgpu = {
      driver = "xe";
      vaapiDriver = "intel-media-driver";
    };

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
    udev.web3.enable = true;

    bluetooth.settings = {
      Experimental = true;
      FastConnectable = true;
      JustWorksRepairing = "always";
      MultiProfile = "multiple";
    };
  };

  system = {
    boot = {
      # The sbctl keys travel with the disk (/var/lib/sbctl). First boot in
      # the Framework needs Secure Boot disabled in BIOS; then put the BIOS
      # in setup mode, run `sudo sbctl enroll-keys --microsoft`, re-enable
      # Secure Boot, and finally re-run `luksCryptenroller` (the old TPM2
      # enrollment is bound to the zenbook's TPM).
      secureBoot = false;
      luksDevicePaths = ["/dev/disk/by-uuid/24dd164a-9843-4e7d-8645-6efccaa7043f"];
      secureBootKeysPath = "/var/lib/sbctl";
      nixConfigurationLimit = 5;
    };

    # Install was born on the zenbook and moved here with the drive
    stateVersion = "24.11";
  };

  environment = {
    sessionVariables = {
      VDPAU_DRIVER = "va_gl"; # VDPAU through VAAPI for Intel
      MOZ_X11_EGL = "1"; # Enable hardware acceleration in Firefox
    };
  };
}
