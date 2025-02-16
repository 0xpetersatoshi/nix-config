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

      systemd = {
        enable = true;
        enableXdgAutostart = true;
        variables = ["--all"];
      };
      xwayland.enable = true;

      settings = {
        "$mainMod" = "SUPER";
        "$terminal" = "ghostty";
        "$fileManager" = "dolphin";
        "$menu" = "rofi -show drun -mode drun";
        "$windowSwitcher" = "rofi -show window";
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
          "col.active_border" = mkForce "rgb(${config.lib.stylix.colors.base0E})";
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
            "systemctl --user import-environment QT_QPA_PLATFORMTHEME"
            # "${pkgs.kanshi}/bin/kanshi"
            "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"
            "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
            "${pkgs.pyprland}/bin/pypr"
            "${pkgs.clipse}/bin/clipse -listen"
            "${pkgs.solaar}/bin/solaar -w hide"
            "${pkgs.hyprpanel}/bin/hyprpanel"
          ]
          ++ cfg.execOnceExtras;
      };
    };
  };
}
