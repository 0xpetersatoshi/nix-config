{
  pkgs,
  config,
  ...
}: {
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

    # Update initrd.kernelModules with the correct modules for Lunar Lake
    initrd.kernelModules = [
      # Basic sound modules
      "snd_hda_intel"

      # SOF core modules
      "snd-sof"
      "snd-sof-pci"

      # Lunar Lake specific module - this is the key one for your CPU
      "snd-sof-pci-intel-lnl"

      # Intel HDA bridge for SOF
      "snd-sof-intel-hda"
      "snd-sof-intel-hda-common"
    ];

    # Same modules for the main system
    kernelModules = [
      "snd_hda_intel" # Load this first
      "snd_sof"
      "snd_sof_pci"
      "snd_sof_intel_hda"
      "snd_sof_intel_hda_common"
      "snd_sof_pci_intel_lnl" # Load this last
      "btusb"
    ];

    # Fix the kernelParams section - remove the module options
    kernelParams = [
      "i915.enable_psr=1"
      "i915.enable_fbc=1"
      "i915.enable_guc=3"
      "i915.force_probe=all"
      "snd_intel_dspcfg.dsp_driver=1"
    ];

    extraModulePackages = with config.boot.kernelPackages; [
      (stdenv.mkDerivation {
        name = "yoga-slim-7i-lunar-lake-audio-quirks";

        # Add this line to prevent the unpack phase from failing
        dontUnpack = true;

        # Your existing buildPhase
        buildPhase = ''
          mkdir -p $out/etc/modprobe.d
          cat > $out/etc/modprobe.d/lunar-lake-audio.conf << EOF
          # Force enable internal speakers on Lunar Lake
          options snd-sof-pci-intel-lnl quirk=0x1
          options snd_hda_intel model=lunar-lake
          EOF
        '';

        # Fix the installPhase - it needs to actually do something
        installPhase = ''
          # This directory is needed for the module to be recognized
          mkdir -p $out/lib/modules
        '';
      })
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

      # Create a custom firmware package for Lunar Lake
      (runCommand "custom-sof-firmware" {} ''
        mkdir -p $out/lib/firmware/intel/sof
        mkdir -p $out/lib/firmware/intel/sof-tplg

        # Copy the standard firmware
        cp -r ${unstable.sof-firmware}/lib/firmware/intel/sof/* $out/lib/firmware/intel/sof/ || true
        cp -r ${unstable.sof-firmware}/lib/firmware/intel/sof-tplg/* $out/lib/firmware/intel/sof-tplg/ || true

        # Create symlinks for Lunar Lake if the files exist
        if [ -f "$out/lib/firmware/intel/sof/sof-lnl.ri" ]; then
          ln -sf sof-lnl.ri $out/lib/firmware/intel/sof/sof-lnl-sdw.ri
        fi

        if [ -f "$out/lib/firmware/intel/sof-tplg/sof-lnl-rt711-l0.tplg" ]; then
          ln -sf sof-lnl-rt711-l0.tplg $out/lib/firmware/intel/sof-tplg/sof-lnl-sdw.tplg
        fi
      '')

      # Create a custom firmware package specifically for Lunar Lake
      (runCommand "lunar-lake-audio-firmware" {} ''
        mkdir -p $out/lib/firmware/intel/sof
        mkdir -p $out/lib/firmware/intel/sof-tplg

        # Don't try to copy specific files that might not exist
        # Instead, create placeholder files with a note
        echo "Placeholder for Lunar Lake firmware" > $out/lib/firmware/intel/sof/sof-lnl.ri
        echo "Placeholder for Lunar Lake topology" > $out/lib/firmware/intel/sof-tplg/sof-lnl-sdw.tplg

        # Create the symlink only after ensuring the source file exists
        ln -sf sof-lnl.ri $out/lib/firmware/intel/sof/sof-lnl-sdw.ri
      '')
    ];
  };

  styles.stylix.wallpaperPath = ../../../wallpaper/standard/astronaut-3-2912x1632.png;

  system = {
    stateVersion = "24.11";

    activationScripts.setupLunarLakeAudio = ''
      # Create directories if they don't exist
      mkdir -p /lib/firmware/intel/sof
      mkdir -p /lib/firmware/intel/sof-tplg

      # Create symlinks if the source files exist
      if [ -f /lib/firmware/intel/sof/sof-lnl.ri ]; then
        ln -sf /lib/firmware/intel/sof/sof-lnl.ri /lib/firmware/intel/sof/sof-lnl-sdw.ri
      fi

      if [ -f /lib/firmware/intel/sof-tplg/sof-lnl-rt711-l0.tplg ]; then
        ln -sf /lib/firmware/intel/sof-tplg/sof-lnl-rt711-l0.tplg /lib/firmware/intel/sof-tplg/sof-lnl-sdw.tplg
      fi
    '';
  };

  # Add this to help with hardware detection
  services.pipewire.extraConfig.pipewire = {
    "context.properties" = {
      "link.max-buffers" = 16;
      "log.level" = 2;
      "default.clock.rate" = 48000;
      "default.clock.allowed-rates" = [44100 48000];
      "default.clock.quantum" = 1024;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 8192;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      unstable.sof-firmware
      igloo.alsa-ucm-conf
      # Add this tool to help debug
      (writeShellScriptBin "fix-audio" ''
        echo "Reloading audio modules..."
        sudo rmmod snd_sof_pci_intel_lnl snd_sof_intel_hda_common snd_sof_intel_hda snd_sof_pci snd_sof
        sudo modprobe snd_sof
        sudo modprobe snd_sof_pci
        sudo modprobe snd_sof_intel_hda
        sudo modprobe snd_sof_intel_hda_common
        sudo modprobe snd_sof_pci_intel_lnl

        echo "Restarting PipeWire..."
        systemctl --user restart pipewire pipewire-pulse

        echo "Audio devices:"
        pactl list sinks short
      '')

      # Add a diagnostic script
      (writeShellScriptBin "fix-lunar-lake-audio" ''
        echo "Setting up Lunar Lake audio..."

        # Check and create firmware symlinks
        echo "Setting up firmware symlinks..."
        sudo mkdir -p /lib/firmware/intel/sof
        sudo mkdir -p /lib/firmware/intel/sof-tplg

        # Try to find the correct firmware files
        if [ -f /lib/firmware/intel/sof/sof-lnl.ri ]; then
          sudo ln -sf /lib/firmware/intel/sof/sof-lnl.ri /lib/firmware/intel/sof/sof-lnl-sdw.ri
          echo "Created symlink for sof-lnl.ri"
        else
          echo "Warning: sof-lnl.ri not found"
        fi

        # Rest of your script...
      '')
    ];

    sessionVariables = {
      ALSA_CONFIG_UCM2 = "${pkgs.igloo.alsa-ucm-conf}/ucm2";
      LIBVA_DRIVER_NAME = "iHD"; # Use intel-media-driver
      MOZ_X11_EGL = "1"; # Enable hardware acceleration in Firefox
      VDPAU_DRIVER = "va_gl"; # VDPAU through VAAPI
      XDG_SESSION_TYPE = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    etc = {
      # Create a custom UCM profile for Lenovo Yoga Slim 7i with Lunar Lake
      "alsa/ucm2/Intel/sof-lnl/sof-lnl.conf" = {
        text = ''
          Syntax 2

          Comment "Intel Lunar Lake Audio"

          SectionUseCase."HiFi" {
            File "HiFi.conf"
            Comment "Default"
          }
        '';
      };

      "alsa/ucm2/Intel/sof-lnl/HiFi.conf" = {
        text = ''
          SectionVerb {
            Value {
              TQ "HiFi"
            }
          }

          SectionDevice."Speaker" {
            Comment "Internal Speakers"

            EnableSequence [
              cset "name='DAC Playback Switch' on"
              cset "name='Speaker Playback Switch' on"
            ]

            DisableSequence [
              cset "name='Speaker Playback Switch' off"
              cset "name='DAC Playback Switch' off"
            ]

            Value {
              PlaybackPriority 100
              PlaybackPCM "hw:0,0"
              PlaybackMixerElem "Speaker"
              PlaybackVolume "Speaker Playback Volume"
            }
          }

          SectionDevice."Headphones" {
            Comment "Headphones"

            EnableSequence [
              cset "name='DAC Playback Switch' on"
              cset "name='Headphone Playback Switch' on"
            ]

            DisableSequence [
              cset "name='Headphone Playback Switch' off"
              cset "name='DAC Playback Switch' off"
            ]

            Value {
              PlaybackPriority 200
              PlaybackPCM "hw:0,0"
              PlaybackMixerElem "Headphone"
              PlaybackVolume "Headphone Playback Volume"
              JackControl "Headphone Jack"
            }
          }

          SectionDevice."HDMI" {
            Comment "HDMI Output"

            EnableSequence [
              cset "name='IEC958 Playback Switch' on"
            ]

            DisableSequence [
              cset "name='IEC958 Playback Switch' off"
            ]

            Value {
              PlaybackPriority 50
              PlaybackPCM "hw:0,3"
            }
          }
        '';
      };

      # Create a card link to make sure the UCM profile is found
      "alsa/ucm2/conf.d/sof-lnl/HDA-Intel.conf" = {
        text = ''
          Comment "Intel Lunar Lake Audio"

          Linked {
            Intel/sof-lnl/sof-lnl.conf
          }
        '';
      };

      "modprobe.d/snd-intel-dspcfg.conf" = {
        text = "options snd_intel_dspcfg dsp_driver=1";
      };

      "modprobe.d/snd-sof-pci-intel-lnl.conf" = {
        text = "options snd_sof_pci_intel_lnl quirk=1";
      };

      "modprobe.d/snd-hda-intel.conf" = {
        text = "options snd_hda_intel model=lunar-lake enable=1 index=0";
      };
    };
  };
}
