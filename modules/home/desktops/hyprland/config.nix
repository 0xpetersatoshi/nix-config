{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.desktops.hyprland;

  autostart =
    [
      "dbus-update-activation-environment --systemd --all"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME"
      "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"
      "${pkgs.kdePackages.kwallet}/bin/kwalletd6"
      "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
      "${pkgs.pyprland}/bin/pypr"
      "${pkgs.clipse}/bin/clipse -listen"
      "${pkgs.syncthingtray}/bin/syncthingtray --wait"
      "${pkgs.solaar}/bin/solaar -w hide"
      "hyprctl dispatch workspace 1"
    ]
    ++ cfg.execOnceExtras;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";

      systemd = {
        # uwsm owns the session -- it starts graphical-session.target itself and
        # imports the environment. Letting HM also start hyprland-session.target
        # double-activates the graphical session.
        enable = false;
        enableXdgAutostart = true;
        variables = ["--all"];
      };
      xwayland.enable = true;

      # Autostart. Must run from the start event rather than at file scope,
      # otherwise every config reload would respawn the whole list.
      extraLuaFiles.autostart = ''
        hl.on("hyprland.start", function()
        ${concatMapStrings (command: "  hl.exec_cmd(${builtins.toJSON command})\n") autostart}end)
      '';

      settings = {
        monitor = mkIf (!cfg.multiMonitor.enable) cfg.monitor;

        env = [
          {_args = ["WLR_DRM_DEVICES" cfg.drmDevices];}
          {_args = ["WLR_NO_HARDWARE_CURSORS" "1"];}
          # https://bbs.archlinux.org/viewtopic.php?pid=2167673#p2167673
          {_args = ["XDG_MENU_PREFIX" "plasma-"];}
        ];

        # Persistent workspaces
        workspace_rule =
          [
            {
              workspace = "1";
              default = true;
              persistent = true;
            }
          ]
          ++ map (n: {
            workspace = toString n;
            persistent = true;
          }) [2 3 4 5]
          ++ [
            {
              workspace = "special:scratchpad";
              on_created_empty = "ghostty";
            }
          ];

        config = {
          input = {
            kb_layout = "us";
            repeat_delay = 200;
            natural_scroll = true;
            touchpad = {
              disable_while_typing = false;
              natural_scroll = true;
              scroll_factor = 0.15;
              tap_and_drag = true;
            };
          };

          general = {
            gaps_in = 3;
            gaps_out = 5;
            border_size = 3;
            "col.active_border" = mkForce "rgb(${config.lib.stylix.colors.base0E})";
          };

          decoration.rounding = 5;

          dwindle.preserve_split = true;

          misc = let
            FULLSCREEN_ONLY = 2;
          in {
            vrr = FULLSCREEN_ONLY;
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            force_default_wallpaper = 0;
            # Follow xdg-activation requests: e.g. clicking a link in another app
            # jumps to the browser's window/workspace instead of just flagging it
            # urgent. (Omarchy enables this in its looknfeel defaults.)
            focus_on_activate = true;
          };
        };
      };
    };
  };
}
