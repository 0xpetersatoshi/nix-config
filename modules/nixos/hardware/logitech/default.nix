{
  pkgs,
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.${namespace}.logitechMouse;
in {
  options.hardware.${namespace}.logitechMouse = with types; {
    enable = mkBoolOpt false "Enable logitech mouse hardware for their mice";
  };

  config = mkIf cfg.enable {
    hardware = {
      logitech.wireless.enable = true;
      logitech.wireless.enableGraphical = true; # Solaar.
    };

    environment.systemPackages = with pkgs; [
      solaar
    ];

    services.udev.packages = with pkgs; [
      logitech-udev-rules
      solaar
    ];
  };
}
