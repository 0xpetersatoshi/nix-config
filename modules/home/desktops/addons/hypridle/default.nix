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
          # Add a small delay before locking to ensure proper shutdown of processes before sleep
          before_sleep_cmd = "hyprland-lock && sleep 0.1 && hyprctl dispatch dpms off";
          # Add a delay after resuming to ensure lock screen is ready before input
          after_sleep_cmd = "hyprland-unlock";
          ignore_dbus_inhibit = false;
          # Ensure lock command is robust
          lock_cmd = "hyprland-lock";
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
