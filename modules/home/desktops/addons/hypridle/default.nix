{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.desktops.addons.hypridle;
  # Access the hasNvidiaGpu option from a shared location
  hasNvidiaGpu = config.hardware.drivers.hasNvidiaGpu or false;
in {
  options.desktops.addons.hypridle = with types; {
    enable = mkBoolOpt false "Whether to enable the hypridle";

    # Define these as functions that take the config as input
    before_sleep_cmd = mkOption {
      type = types.str;
      default = "";
      description = "Command to run before sleep";
    };

    after_sleep_cmd = mkOption {
      type = types.str;
      default = "";
      description = "Command to run after sleep";
    };

    lock_cmd = mkOption {
      type = types.str;
      default = "";
      description = "Command to lock the screen";
    };
  };

  config = mkIf cfg.enable {
    # Set the values based on the hasNvidiaGpu option
    desktops.addons.hypridle = {
      before_sleep_cmd =
        if hasNvidiaGpu
        then "hyprland-lock && sleep 0.1 && hyprctl dispatch dpms off"
        else "loginctl lock-session && hyprctl dispatch dpms off";

      after_sleep_cmd =
        if hasNvidiaGpu
        then "hyprland-unlock"
        else "hyprctl dispatch dpms on";

      lock_cmd =
        if hasNvidiaGpu
        then "hyprland-lock"
        else "pidof hyprlock || hyprlock";
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = cfg.before_sleep_cmd;
          after_sleep_cmd = cfg.after_sleep_cmd;
          ignore_dbus_inhibit = false;
          lock_cmd = cfg.lock_cmd;
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
