{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.input-devices.touchpad;
in {
  options.hardware.input-devices.touchpad = with types; {
    enable = mkBoolOpt false "Enable touchpad configuration";
  };

  config = mkIf cfg.enable {
    services.libinput = {
      enable = true;
      touchpad = {
        accelProfile = "flat";
        accelSpeed = "0";
        accelStepScroll = 0.1;
        naturalScrolling = true;
      };
    };
  };
}
