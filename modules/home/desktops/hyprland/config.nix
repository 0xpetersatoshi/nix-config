{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.desktops.hyprland;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;

      systemd.enable = true;
      systemd.enableXdgAutostart = true;
      xwayland.enable = true;

      settings = {
        "$mainMod" = "SUPER";
        "$terminal" = "ghostty";
        "$fileManager" = "dolphin";
        "$menu" = "rofi -show drun -mode drun";
        "$notificationsClient" = "swaync-client -t";
        "$browser" = "zen";
        "$passwordManager" = "1password";
        "$editor" = "nvim";
        "$music" = "spotify";
        monitor = ",preferred,auto,auto";
        input = {
          kb_layout = "us";
          touchpad = {
            disable_while_typing = false;
          };
        };

        general = {
          gaps_in = 3;
          gaps_out = 5;
          border_size = 3;
        };

        decoration = {
          rounding = 5;
        };

        misc = let
          FULLSCREEN_ONLY = 2;
        in {
          vrr = FULLSCREEN_ONLY;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
        };

        exec-once =
          [
            "dbus-update-activation-environment --systemd --all"
            # "systemctl --user import-environment QT_QPA_PLATFORMTHEME"
            # "${pkgs.kanshi}/bin/kanshi"
            "${pkgs.waybar}/bin/waybar"
            "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
            "${pkgs.pyprland}/bin/pypr"
            "${pkgs.clipse}/bin/clipse -listen"
            "${pkgs.solaar}/bin/solaar -w hide"
          ]
          ++ cfg.execOnceExtras;
      };
    };
  };
}
