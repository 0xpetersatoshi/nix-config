{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.system.boot;
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
  };

  config = mkIf cfg.enable {
    boot = {
      initrd.systemd.enable = true;

      loader = {
        efi = {
          canTouchEfiVariables = true;
        };

        systemd-boot = {
          enable = true;

          configurationLimit = cfg.nixConfigurationLimit;
        };
      };
    };
  };
}
