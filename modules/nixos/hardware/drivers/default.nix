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
in {
  options.hardware.drivers = with types; {
    enable = mkBoolOpt false "Enable or disable hardware drivers based on available hardware";
    hasAmdCpu = mkBoolOpt false "Whether or not the system has an AMD CPU";
    hasIntelCpu = mkBoolOpt false "Whether or not the system has an Intel CPU";
    hasIntelGpu = mkBoolOpt false "Whether or not the system has an Intel GPU";
    hasAmdGpu = mkBoolOpt false "Whether or not the system has an AMD GPU";
    hasNvidiaGpu = mkBoolOpt false "Whether or not the system has an Nvidia GPU";
    hasOlderIntelCpu = mkBoolOpt false "Whether or not the system has an older Intel CPU";
    hasIntegratedGpu = mkBoolOpt false "Wether the system has an iGPU";
    vulkanEnabled = mkBoolOpt false "Wether to enable vulkan support for AMD GPUs";
  };

  config = mkIf cfg.enable {
    # Load drivers for Xorg and Wayland

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs;
          lib.optionals ((cfg.hasNvidiaGpu && !cfg.hasIntegratedGpu) || cfg.hasIntelGpu) [
            libva-vdpau-driver
          ]
          # Intel GPU packages
          ++ lib.optionals cfg.hasIntelGpu [
            vpl-gpu-rt
            libvpl
            libvdpau-va-gl
          ]
          # Intel Cpu packages
          ++ lib.optionals cfg.hasIntelCpu [
            intel-media-driver
          ]
          ++ lib.optionals cfg.hasOlderIntelCpu [
            intel-vaapi-driver
          ];
        extraPackages32 = pkgs.lib.flatten (
          with pkgs; [
            # Nvidia/Intel shared GPU packages
            (lib.optional ((cfg.hasNvidiaGpu && !cfg.hasIntegratedGpu) || cfg.hasIntelGpu) libva-vdpau-driver)

            # Intel Cpu packages
            (lib.optional cfg.hasIntelCpu intel-media-driver)
            (lib.optional cfg.hasOlderIntelCpu intel-vaapi-driver)
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
          finegrained = cfg.hasIntegratedGpu;
        };

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        # The open driver is recommended by nvidia now, see
        # https://download.nvidia.com/XFree86/Linux-x86_64/565.57.01/README/kernel_open.html
        open = true;

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

        # If this is enabled, then the bus IDs of the NVIDIA and Intel/AMD GPUs have to be specified
        prime = {
          offload = {
            enable = cfg.hasIntegratedGpu;
            enableOffloadCmd = cfg.hasIntegratedGpu;
          };
        };
      };

      amdgpu = mkIf cfg.hasAmdGpu {
        opencl.enable = true;
        initrd.enable = true;
        amdvlk.enable = cfg.vulkanEnabled;
      };
    };

    # Boot configuration for GPU support
    boot = {
      # Kernel parameters
      kernelParams = with pkgs.lib;
        []
        ++ (optionals cfg.hasAmdCpu ["amd_pstate=active"]);

      # Kernel modules
      kernelModules = with pkgs.lib;
        []
        ++ (optionals cfg.hasIntelGpu ["xe"])
        ++ (optionals cfg.hasAmdGpu ["amdgpu"]);

      # Module blacklisting
      blacklistedKernelModules = with pkgs.lib;
        [] ++ (optionals cfg.hasAmdGpu ["radeon"]);

      # Extra modprobe config for Nvidia
      extraModprobeConfig = pkgs.lib.mkIf cfg.hasNvidiaGpu ''
        options nvidia NVreg_UsePageAttributeTable=1
      '';
    };

    # Environment packages for GPU support
    environment.systemPackages = with pkgs;
      lib.optionals cfg.hasAmdGpu [
        radeontop
      ]
      ++ lib.optionals cfg.vulkanEnabled [
        vulkan-tools
      ]
      ++ lib.optionals cfg.hasNvidiaGpu [
        nvtopPackages.nvidia
      ]
      ++ lib.optionals cfg.hasIntelGpu [
        intel-gpu-tools
        nvtopPackages.intel
      ]
      ++ lib.optionals ((cfg.hasNvidiaGpu && !cfg.hasIntegratedGpu) || cfg.hasIntelGpu) [
        libva-vdpau-driver
        vulkan-tools
      ]
      ++ [
        clinfo
        glxinfo
        libva-utils
        vdpauinfo
      ];
  };
}
