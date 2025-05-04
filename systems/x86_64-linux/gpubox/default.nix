{
  pkgs,
  namespace,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  boot = {
    kernelPackages = pkgs.unstable.linuxPackages_latest;
    initrd.kernelModules = ["amdgpu"];
  };

  environment = {
    sessionVariables = {
      # Configure VAAPI and VDPAU drivers for video acceleration
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
    };

    systemPackages = with pkgs; [
      firefox
      lact
    ];
  };

  hardware = {
    drivers = {
      enable = true;
      hasAmdCpu = true;
      hasAmdGpu = true;
      vulkanEnabled = true;
    };

    enableAllFirmware = true;
  };

  hardware.${namespace} = {
    audio.enable = true;
    bluetooth.enable = true;
  };

  networking.hostName = "gpubox";

  roles = {
    common.enable = true;
    gaming = {
      enable = true;
      bootToSteamDeck = true;
    };
  };

  services = {
    desktopManager.plasma6.enable = true;
    xserver.videoDrivers = ["amdgpu" "modeset"];
  };

  services.${namespace}.ollama = {
    enable = true;
    loadModels = [
      "deepseek-r1:32b"
    ];
    rocmOverrideGfx = "11.0.0";
  };

  system = {
    boot.nixConfigurationLimit = 5;
    stateVersion = "24.11";
  };

  users.users.peter.isNormalUser = false;
}
