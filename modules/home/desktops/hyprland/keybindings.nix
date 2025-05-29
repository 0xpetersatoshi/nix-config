{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.desktops.hyprland;

  resize = pkgs.writeShellScriptBin "resize" ''
    #!/usr/bin/env bash

    # Initially inspired by https://github.com/exoess

    # Getting some information about the current window
    # windowinfo=$(hyprctl activewindow) removes the newlines and won't work with grep
    hyprctl activewindow > /tmp/windowinfo
    windowinfo=/tmp/windowinfo

    # Run slurp to get position and size
    if ! slurp=$(slurp); then
    		exit
    fi

    # Parse the output
    pos_x=$(echo $slurp | cut -d " " -f 1 | cut -d , -f 1)
    pos_y=$(echo $slurp | cut -d " " -f 1 | cut -d , -f 2)
    size_x=$(echo $slurp | cut -d " " -f 2 | cut -d x -f 1)
    size_y=$(echo $slurp | cut -d " " -f 2 | cut -d x -f 2)

    # Keep the aspect ratio intact for PiP
    #
    if grep "title: Picture-in-Picture" $windowinfo; then
    		old_size=$(grep "size: " $windowinfo | cut -d " " -f 2)
    		old_size_x=$(echo $old_size | cut -d , -f 1)
    		old_size_y=$(echo $old_size | cut -d , -f 2)

    		size_x=$(((old_size_x * size_y + old_size_y / 2) / old_size_y))
    		echo $old_size_x $old_size_y $size_x $size_y
    fi

    # Resize and move the (now) floating window
    grep "fullscreen: 1" $windowinfo && hyprctl dispatch fullscreen
    grep "floating: 0" $windowinfo && hyprctl dispatch togglefloating
    hyprctl dispatch moveactive exact $pos_x $pos_y
    hyprctl dispatch resizeactive exact $size_x $size_y
  '';

  increaseBrightnessCommand =
    if cfg.hasLunarLakeCPU
    then "${pkgs.light}/bin/light -A 5"
    else "${pkgs.brightnessctl}/bin/brightnessctl +5%";
  decreaseBrightnessCommand =
    if cfg.hasLunarLakeCPU
    then "${pkgs.light}/bin/light -U 5"
    else "${pkgs.brightnessctl}/bin/brightnessctl -5%";
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      "$pypr" = "${pkgs.pyprland}/bin/pypr";
      bind = [
        "SUPER, T, exec, $terminal"
        "SUPER, B, exec, $browser"
        "SUPER, Space, exec, $menu"
        "SUPER, Q, killactive,"
        "SUPER, E, exec, $fileManager"
        "SUPER, F, Fullscreen,0"
        "SUPER, R, exec, ${resize}/bin/resize"
        "SUPER, G, togglefloating,"
        "SUPER, N, exec, hyprpanel toggleWindow notificationsmenu"
        "SUPER, P, exec, $passwordManager"
        "SUPER, V, exec, $pypr toggle pwvucontrol"
        "SUPER_SHIFT, T, exec, $pypr toggle term"
        ",XF86ScreenSaver, exec, ${pkgs.hyprlock}/bin/hyprlock"
        ",XF86Calculator, exec, ${pkgs.kdePackages.kcalc}/bin/kcalc"
        "SUPER, backspace, exec, ${pkgs.hyprlock}/bin/hyprlock"
        "SUPER, delete, exec, wlogout --column-spacing 50 --row-spacing 50"
        ",Print, exec, grimblast --notify copysave area"
        "SHIFT, Print, exec, grimblast --notify copy active"
        "CONTROL, Print, exec, grimblast --notify copy screen"
        "SUPER, Print, exec, grimblast --notify copy window"
        "ALT, Print, exec, grimblast --notify copy area"
        "SUPER, Tab, exec, $windowSwitcher"
        "SUPER,bracketleft, exec,grimblast --notify --cursor copysave area ~/Pictures/$(date \" + %Y-%m-%d \"T\"%H:%M:%S_no_watermark \").png"
        "SUPER,bracketright, exec, grimblast --notify --cursor copy area"
        "SUPER,h, movefocus,l"
        "SUPER,l, movefocus,r"
        "SUPER,k, movefocus,u"
        "SUPER,j, movefocus,d"
        "SUPERCONTROL,h, focusmonitor,l"
        "SUPERCONTROL,l, focusmonitor,r"
        "SUPERCONTROL,k, focusmonitor,u"
        "SUPERCONTROL,j, focusmonitor,d"
        "SUPER,1, workspace,01"
        "SUPER,2, workspace,02"
        "SUPER,3, workspace,03"
        "SUPER,4, workspace,04"
        "SUPER,5, workspace,05"
        "SUPER,6, workspace,06"
        "SUPER,7, workspace,07"
        "SUPER,8, workspace,08"
        "SUPER,9, workspace,09"
        "SUPER,0, workspace,10"
        "SUPERSHIFT,1, movetoworkspacesilent,01"
        "SUPERSHIFT,2, movetoworkspacesilent,02"
        "SUPERSHIFT,3, movetoworkspacesilent,03"
        "SUPERSHIFT,4, movetoworkspacesilent,04"
        "SUPERSHIFT,5, movetoworkspacesilent,05"
        "SUPERSHIFT,6, movetoworkspacesilent,06"
        "SUPERSHIFT,7, movetoworkspacesilent,07"
        "SUPERSHIFT,8, movetoworkspacesilent,08"
        "SUPERSHIFT,9, movetoworkspacesilent,09"
        "SUPERSHIFT,0, movetoworkspacesilent,10"
        "SUPERALT,h, movecurrentworkspacetomonitor,l"
        "SUPERALT,l, movecurrentworkspacetomonitor,r"
        "SUPERALT,k, movecurrentworkspacetomonitor,u"
        "SUPERALT,j, movecurrentworkspacetomonitor,d"
        "ALTCTRL,L, movewindow,r"
        "ALTCTRL,H, movewindow,l"
        "ALTCTRL,K, movewindow,u"
        "ALTCTRL,J, movewindow,d"
        "SUPERSHIFT,h, swapwindow,l"
        "SUPERSHIFT,l, swapwindow,r"
        "SUPERSHIFT,k, swapwindow,u"
        "SUPERSHIFT,j, swapwindow,d"
        "SUPER,u, togglespecialworkspace"
        "SUPERSHIFT,u, movetoworkspace,special"
        "SUPER, F7, exec, hyprctl keyword monitor \"${cfg.multiMonitor.laptopMonitor},disable\""
        "SUPER SHIFT, F7, exec, hyprctl keyword monitor \"${cfg.multiMonitor.laptopMonitor},${cfg.multiMonitor.laptopResolution},1280x2160,${toString cfg.multiMonitor.laptopScale}\""
      ];
      bindi = [
        ",XF86MonBrightnessUp, exec, ${increaseBrightnessCommand}"
        ",XF86MonBrightnessDown, exec, ${decreaseBrightnessCommand}"
        ",XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer -i 5"
        ",XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer -d 5"
        ",XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer --toggle-mute"
        ",XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/pamixer --default-source --toggle-mute"
        ",XF86AudioNext, exec,playerctl next"
        ",XF86AudioPrev, exec,playerctl previous"
        ",XF86AudioPlay, exec,playerctl play-pause"
        ",XF86AudioStop, exec,playerctl stop"
      ];
      bindl = mkIf cfg.enable (
        [
          # Other bindings...
        ]
        ++ (optionals cfg.multiMonitor.enable [
          ",switch:Lid Switch, exec, ${cfg.multiMonitor.monitorScript}/bin/handle-monitors"
        ])
      );
      binde = [
        "SUPERALT, h, resizeactive, -20 0"
        "SUPERALT, l, resizeactive, 20 0"
        "SUPERALT, k, resizeactive, 0 -20"
        "SUPERALT, j, resizeactive, 0 20"
      ];
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };
}
