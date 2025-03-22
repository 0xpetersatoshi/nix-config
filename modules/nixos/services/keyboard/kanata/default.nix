{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.keyboard.kanata;
in {
  options.services.keyboard.kanata = {
    enable = mkEnableOption "kanata keyboard remapper";

    configFile = mkOption {
      type = types.path;
      description = "Path to the kanata configuration file";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra arguments to pass to kanata";
    };

    extraDefCfg = mkOption {
      type = types.str;
      default = "process-unmapped-keys yes";
      description = "Configuration of defcfg other than linux-dev (generated from the devices option) and linux-continue-if-no-devs-found (hardcoded to be yes).";
    };
  };

  config = mkIf cfg.enable {
    services.kanata = {
      enable = true;
      keyboards = {
        internal = {
          devices = [
            "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
          ];
          config = builtins.readFile cfg.configFile;
          extraArgs = cfg.extraArgs;
          extraDefCfg = cfg.extraDefCfg;
        };
      };
    };

    # Install kanata package
    environment.systemPackages = [pkgs.kanata];
  };
}
