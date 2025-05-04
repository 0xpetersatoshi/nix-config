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
    kernelPackages = pkgs.linuxPackages_latest;
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

  jovian = {
    decky-loader = {
      enable = true;
    };
    hardware = {
      has.amd.gpu = true;
      amd.gpu.enableBacklightControl = false;
    };
    steam = {
      updater.splash = "steamos";
      enable = true;
      autoStart = true;
      user = "peter";
      desktopSession = "plasma";
    };
    steamos = {
      useSteamOSConfig = true;
    };
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
    audio.enable = false;
    bluetooth.enable = true;
  };

  networking.hostName = "gpubox";

  roles = {
    gaming = {
      enable = true;
      gamescopeEnabled = false;
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
    boot = {
      enable = true;
      nixConfigurationLimit = 5;
    };
    nix.enable = true;
    locale.enable = true;
    zram.enable = true;
    stateVersion = "24.11";
  };

  user = {
    name = "peter";
    initialPassword = "1";
    isNormalUser = true;
  };
}
