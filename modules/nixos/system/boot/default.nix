{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;
  cfg = config.system.boot;

  # Create the luksCryptenroller script using the configured LUKS device paths
  luksCryptenroller = pkgs.writeTextFile {
    name = "luksCryptenroller";
    destination = "/bin/luksCryptenroller";
    executable = true;
    text = let
      # Generate enrollment commands for each LUKS device
      enrollCommands =
        lib.concatMapStrings (device: ''
          echo "Enrolling LUKS device: ${device}"
          sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+7 ${device}
        '')
        cfg.luksDevicePaths;
    in ''
      #!/bin/sh
      # Auto-generated LUKS TPM2 enrollment script

      if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root" >&2
        exit 1
      fi

      # Show available LUKS devices for reference
      echo "Available LUKS devices:"
      lsblk -o NAME,TYPE,FSTYPE,MOUNTPOINT,LABEL,UUID | grep -i luks
      echo ""

      ${enrollCommands}

      echo "TPM2 enrollment complete"
    '';
  };
in {
  options.system.boot = {
    enable = mkBoolOpt false "Whether or not to enable booting.";
    plymouth = mkBoolOpt false "Whether or not to enable plymouth boot splash.";
    secureBoot = mkBoolOpt false "Whether or not to enable secure boot.";
    nixConfigurationLimit = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Number of NixOS generations kept in the boot menu";
    };

    # Add an option for LUKS device paths
    luksDevicePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of LUKS device paths to enroll with TPM2 (e.g., /dev/sda2)";
      example = ["/dev/sda2" "/dev/nvme0n1p3"];
    };
  };

  config = mkIf cfg.enable {
    boot = {
      initrd.systemd.enable = true;

      lanzaboote = mkIf cfg.secureBoot {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };

      loader = {
        efi = {
          canTouchEfiVariables = true;
        };

        # Lanzaboote currently replaces the systemd-boot module.
        systemd-boot = {
          enable = !cfg.secureBoot;
          configurationLimit = cfg.nixConfigurationLimit;
        };
      };
    };

    environment.systemPackages = with pkgs;
    # For debugging and troubleshooting Secure Boot.
      lib.optionals
      cfg.secureBoot
      [
        tpm2-tss
        sbctl
        cryptsetup # Add cryptsetup for LUKS management
      ]
      ++ lib.optionals (cfg.secureBoot && cfg.luksDevicePaths != []) [
        luksCryptenroller
      ];
  };
}
