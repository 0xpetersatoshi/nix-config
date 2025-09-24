{
  config,
  lib,
  pkgs,
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
        "$calculatorWindow" = "rofi -show calc -modi calc -calc-command \"echo -n '{result}' | wl-copy\"";
        # "$notificationsClient" = "swaync-client -t";
        "$browser" = "firefox";
        "$passwordManager" = "1password";
        "$editor" = "nvim";
        "$music" = "spotify";
        monitor = mkIf (!cfg.multiMonitor.enable) cfg.monitor;

        # Add environment variables here
        env = [
          "WLR_DRM_DEVICES,${cfg.drmDevices}"
          "WLR_NO_HARDWARE_CURSORS,1"
          # https://bbs.archlinux.org/viewtopic.php?pid=2167673#p2167673
          "XDG_MENU_PREFIX,plasma-"
        ];

        # Create persistent workspaces
        workspace = [
          "1, default:true persistent:true"
          "2, persistent:true"
          "3, persistent:true"
          "4, persistent:true"
          "5, persistent:true"
          "special:scratchpad, on-created-empty:ghostty"
        ];

        input = {
          kb_layout = "us";
          repeat_delay = 200;
          natural_scroll = true;
          touchpad = {
            disable_while_typing = false;
            natural_scroll = true;
            scroll_factor = 0.15;
            tap-and-drag = true;
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
            "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME"
            # "${pkgs.kanshi}/bin/kanshi"
            "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"
            "${pkgs.kdePackages.kwallet}/bin/kwalletd6"
            "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
            "${pkgs.pyprland}/bin/pypr"
            "${pkgs.clipse}/bin/clipse -listen"
            # "${pkgs.trayscale}/bin/trayscale"
            "${pkgs.syncthingtray}/bin/syncthingtray --wait"
            "${pkgs.solaar}/bin/solaar -w hide"
            # "${pkgs.hyprpanel}/bin/hyprpanel"
            "hyprctl dispatch workspace 1"
          ]
          ++ lib.optionals config.desktops.addons.kde.enable ["${kdePackages.plasma-nm}/bin/nm-tray"]
          ++ cfg.execOnceExtras;
      };
    };
  };
}
