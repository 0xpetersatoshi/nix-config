{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.desktops.addons.hypridle;
in {
  options.desktops.addons.hypridle = with types; {
    enable = mkBoolOpt false "Whether to enable the hypridle";
  };

  config = mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "loginctl lock-session && hyprctl dispatch dpms off";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "pidof hyprlock || hyprlock";
        };

        listener = [
          {
            timeout = 180;
            on-timeout = "brightnessctl -s set 30";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 1200;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
