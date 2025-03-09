{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  services.xserver.videoDrivers = ["nvidia"];

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

  networking.hostName = "nixbox";

  boot = {
    # supportedFilesystems = lib.mkForce ["btrfs"];
    kernelPackages = pkgs.linuxPackages_zen;
    # resumeDevice = "/dev/disk/by-label/nixos";
  };

  hardware = {
    drivers = {
      enable = true;
      hasAmdCpu = true;
      hasNvidiaGpu = true;
    };

    suspend = {
      enable = true;
      hasAmdCpu = true;
      hasNvidiaGpu = true;
    };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    # NOTE: stylix override
    # QT_STYLE_OVERRIDE = "kvantum";
  };

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "safe-suspend" ''
      # Keep only the keyboard's controller enabled
      KEYBOARD_CONTROLLER="00:02.1"

      # Disable all wake sources except the keyboard's controller and power button
      for device in $(cat /proc/acpi/wakeup | grep enabled | awk '{print $1}'); do
        # Get the PCI path for this device
        PCI_PATH=$(grep "$device" /proc/acpi/wakeup | awk '{print $4}')

        # Skip if it's the keyboard's controller
        # if [[ "$PCI_PATH" == *"$KEYBOARD_CONTROLLER"* ]]; then
        #   echo "Keeping $device enabled (has keyboard)"
        #   continue
        # fi

        # Skip if it's the power button (if present)
        if [[ "$device" == "PWRB" ]]; then
          echo "Keeping power button enabled"
          continue
        fi

        # Disable this wake source
        echo "Disabling $device"
        echo "$device" > /proc/acpi/wakeup
      done

      # Now suspend
      systemctl suspend
    '')
  ];

  system.stateVersion = "24.11";
}
