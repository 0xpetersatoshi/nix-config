{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hardware.${namespace}.bluetooth;
in {
  options.hardware.${namespace}.bluetooth = {
    enable = mkEnableOption "Enable bluetooth service and packages";
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        FastConnectable = true;
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
      };
      description = "Default bluetooth settings";
    };
  };

  config = mkIf cfg.enable {
    services.blueman.enable = true;
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = cfg.settings;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      bluez-tools
    ];
  };
}
