{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.drivers;
  needsMesa = cfg.hasAmdGpu || cfg.hasIntelCpu || cfg.hasOlderIntelCpu;
in {
  options.hardware.drivers = with types; {
    enable = mkBoolOpt false "Enable or disable hardware drivers based on available hardware";
    hasAmdCpu = mkBoolOpt false "Whether or not the system has an AMD CPU";
    hasIntelCpu = mkBoolOpt false "Whether or not the system has an Intel CPU";
    hasIntelGpu = mkBoolOpt false "Whether or not the system has an Intel GPU";
    hasAmdGpu = mkBoolOpt false "Whether or not the system has an AMD GPU";
    hasNvidiaGpu = mkBoolOpt false "Whether or not the system has an Nvidia GPU";
    hasOlderIntelCpu = mkBoolOpt false "Whether or not the system has an older Intel CPU";
  };

  config = mkIf cfg.enable {
    # NOTE: config mostly taken from: https://github.com/richen604/hydenix/blob/main/hosts/nixos/drivers.nix
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = pkgs.lib.flatten (
          with pkgs; [
            # AMD GPU packages
            (lib.optional cfg.hasAmdGpu amdvlk)

            # Nvidia GPU packages
            (lib.optional cfg.hasNvidiaGpu nvidia-vaapi-driver)

            # Nvidia/Intel shared GPU packages
            (lib.optional (cfg.hasNvidiaGpu || cfg.hasIntelGpu) libva-vdpau-driver)

            # Intel Cpu packages
            (lib.optional cfg.hasIntelCpu intel-media-driver)
            (lib.optional cfg.hasOlderIntelCpu intel-vaapi-driver)

            # Mesa
            (lib.optional needsMesa mesa)
          ]
        );
        extraPackages32 = pkgs.lib.flatten (
          with pkgs; [
            # AMD GPU packages
            (lib.optional cfg.hasAmdGpu amdvlk)

            # Nvidia/Intel shared GPU packages
            (lib.optional (cfg.hasNvidiaGpu || cfg.hasIntelGpu) libva-vdpau-driver)

            # Intel Cpu packages
            (lib.optional cfg.hasIntelCpu intel-media-driver)
            (lib.optional cfg.hasOlderIntelCpu intel-vaapi-driver)

            # Mesa
            (lib.optional needsMesa mesa)
          ]
        );
      };

      # CPU Configuration
      cpu = {
        amd.updateMicrocode = cfg.hasAmdCpu;
        intel.updateMicrocode = cfg.hasIntelCpu || cfg.hasOlderIntelCpu;
      };

      # Nvidia specific configuration
      nvidia = pkgs.lib.mkIf cfg.hasNvidiaGpu {
        # Modesetting is required.
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        # Enable this if you have graphical corruption issues or application crashes after waking
        # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
        # of just the bare essentials.
        powerManagement = {
          enable = true;

          # Fine-grained power management. Turns off GPU when not in use.
          # Experimental and only works on modern Nvidia GPUs (Turing or newer).
          finegrained = false;
        };

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        # Currently alpha-quality/buggy, so false is currently the recommended setting.
        open = false;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = config.boot.kernelPackages.nvidiaPackages.stable;

        # Screen Tearing Issues
        # First, try to switch to PRIME Sync Mode, as described above. If that doesn't work, try forcing a composition pipeline.
        # Note: Forcing a full composition pipeline has been reported to reduce the performance of some OpenGL applications and
        # may produce issues in WebGL. It also drastically increases the time the driver needs to clock down after load.
        forceFullCompositionPipeline = false;
      };
    };

    # Boot configuration for GPU support
    boot = {
      # Kernel parameters
      kernelParams = with pkgs.lib;
        []
        ++ (optionals cfg.hasAmdCpu ["amd_pstate=active"])
        ++ (optionals cfg.hasAmdGpu [
          "radeon.si_support=0"
          "amdgpu.si_support=1"
        ])
        ++ (optionals cfg.hasNvidiaGpu ["nvidia-drm.modeset=1"]);

      # Kernel modules
      kernelModules = with pkgs.lib;
        []
        ++ (optionals cfg.hasAmdCpu ["kvm-amd"])
        ++ (optionals (cfg.hasIntelCpu || cfg.hasOlderIntelCpu) ["kvm-intel"])
        ++ (optionals cfg.hasIntelGpu ["xe"])
        ++ (optionals cfg.hasAmdGpu ["amdgpu"])
        ++ (optionals cfg.hasNvidiaGpu [
          "nvidia"
          "nvidia_drm"
          "nvidia_modeset"
        ]);

      # Module blacklisting
      blacklistedKernelModules = with pkgs.lib;
        [] ++ (optionals cfg.hasAmdGpu ["radeon"]) ++ (optionals cfg.hasNvidiaGpu ["nouveau"]);

      # Extra modprobe config for Nvidia
      extraModprobeConfig = pkgs.lib.mkIf cfg.hasNvidiaGpu ''
        options nvidia-drm modeset=1
        options nvidia NVreg_PreserveVideoMemoryAllocations=1
      '';
    };

    # Environment packages for GPU support
    environment.systemPackages = with pkgs;
      lib.optionals needsMesa [
        mesa
      ]
      ++ lib.optionals cfg.hasAmdGpu [
        vulkan-tools
        vulkan-loader
        vulkan-validation-layers
        amdvlk
      ]
      ++ lib.optionals cfg.hasNvidiaGpu [
        nvtopPackages.nvidia
        nvidia-vaapi-driver
        vulkan-loader
        vulkan-validation-layers
      ]
      ++ lib.optionals cfg.hasIntelGpu [
        intel-gpu-tools
      ]
      ++ lib.optionals (cfg.hasNvidiaGpu || cfg.hasIntelGpu) [
        libva-vdpau-driver
        vulkan-tools
      ]
      ++ [
        glxinfo
        libva-utils
        mpv
        vdpauinfo
      ];
  };
}
