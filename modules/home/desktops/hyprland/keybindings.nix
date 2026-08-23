{
  pkgs,
  config,
  lib,
  namespace,
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

  isDms = cfg.bar == "dms";

  pypr = "${pkgs.pyprland}/bin/pypr";

  terminal = "ghostty";
  fileManager = "nautilus --new-window";
  browser = "brave";
  browserWork = "brave -P Work";
  passwordManager = "1password";
  music = "spotify";

  # Flip the active workspace between dwindle and scrolling. `hyprctl eval`
  # only works under the Lua config manager; fall back to the hyprlang keyword
  # so this works either way.
  layoutToggle = pkgs.writeShellScriptBin "hypr-layout-toggle" ''
    ws=$(hyprctl activeworkspace -j)
    id=$(jq -r '.id' <<<"$ws")
    [[ $id =~ ^-?[0-9]+$ ]] || exit 1

    case "$(jq -r '.tiledLayout' <<<"$ws")" in
      dwindle) new=scrolling ;;
      *) new=dwindle ;;
    esac

    hyprctl eval "hl.workspace_rule({ workspace = \"$id\", layout = \"$new\" })" >/dev/null 2>&1 ||
      hyprctl keyword workspace "$id, layout:$new"

    notify-send -t 1500 "Workspace layout: $new"
  '';

  increaseBrightnessCommand = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
  decreaseBrightnessCommand = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";

  lockCommand =
    if isDms
    then "dms ipc call lock lock"
    else "${pkgs.hyprlock}/bin/hyprlock";

  logoutCommand =
    if isDms
    then "dms ipc call powermenu toggle"
    else "wlogout --column-spacing 50 --row-spacing 50";

  menuCommand =
    if isDms
    then "dms ipc call spotlight toggle"
    else "walker";

  screenshot = "${pkgs.${namespace}.omarchy-capture-screenshot}/bin/omarchy-capture-screenshot";
  captureText = "${pkgs.${namespace}.omarchy-capture-text}/bin/omarchy-capture-text";
  screenrecord = "${pkgs.${namespace}.omarchy-capture-screenrecording}/bin/omarchy-capture-screenrecording";
  captureRegion = "${pkgs.${namespace}.omarchy-capture-region}/bin/omarchy-capture-region";

  notificationToggleCommand =
    if isDms
    then "dms ipc call notifications toggle"
    else if cfg.bar == "hyprpanel"
    then "hyprpanel toggleWindow notificationsmenu"
    else "sleep 0.1 && swaync-client -t -sw";

  inherit (cfg.multiMonitor) laptopMonitor laptopResolution laptopScale;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.extraLuaFiles.bindings = ''
      local mod = "SUPER"

      -- Applications
      hl.bind(mod .. " + A", hl.dsp.exec_cmd("${pypr} toggle pwvucontrol"))
      hl.bind(mod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("${browser}"))
      hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("${browserWork}"))
      hl.bind(mod .. " + E", hl.dsp.exec_cmd("${fileManager}"))
      hl.bind(mod .. " + M", hl.dsp.exec_cmd("${music}"))
      hl.bind(mod .. " + N", hl.dsp.exec_cmd("${notificationToggleCommand}"))
      hl.bind(mod .. " + P", hl.dsp.exec_cmd("${passwordManager}"))
      hl.bind(mod .. " + R", hl.dsp.exec_cmd("${resize}/bin/resize"))
      hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("${terminal}"))
      hl.bind(mod .. " + Y", hl.dsp.exec_cmd("yubioath-flutter"))
      hl.bind(mod .. " + Space", hl.dsp.exec_cmd("${menuCommand}"))
      hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("${pypr} toggle term"))
      hl.bind("XF86Calculator", hl.dsp.exec_cmd("${pkgs.kdePackages.kcalc}/bin/kcalc"))

      -- Session
      hl.bind("XF86ScreenSaver", hl.dsp.exec_cmd("${lockCommand}"))
      hl.bind(mod .. " + backspace", hl.dsp.exec_cmd("${lockCommand}"))
      hl.bind(mod .. " + delete", hl.dsp.exec_cmd("${logoutCommand}"))

      -- Screenshots (Omarchy-style: frozen screen, window snapping,
      -- keyboard selection with Tab/arrows/Enter while the picker is up).
      hl.bind("Print", hl.dsp.exec_cmd("${screenshot}"))                                  -- smart pick -> save + clipboard + edit toast
      hl.bind("SHIFT + Print", hl.dsp.exec_cmd("${screenshot} windows"))                  -- snap to a window or monitor rectangle
      hl.bind("CONTROL + Print", hl.dsp.exec_cmd("${screenshot} fullscreen"))             -- whole focused monitor
      hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("${screenshot} region copy"))    -- freeform region, clipboard only
      hl.bind(mod .. " + CONTROL + Print", hl.dsp.exec_cmd("${captureText}"))             -- OCR the region to the clipboard
      hl.bind(mod .. " + Print", hl.dsp.exec_cmd("pkill hyprpicker || ${pkgs.hyprpicker}/bin/hyprpicker -a"))

      -- Keyboard control for the slurp region picker. The binds live exactly as
      -- long as a selection layer is on screen (slurp opens one per monitor),
      -- so they cannot leak or get stuck. Unbinding by key would take a
      -- same-key binding out of this config with it, so each handle is kept
      -- and removed individually.
      local selection_layers = 0
      local selection_binds = {}

      hl.on("layer.opened", function(layer)
        if layer.namespace == "selection" then
          selection_layers = selection_layers + 1
          if selection_layers == 1 then
            selection_binds = {
              hl.bind("RETURN", hl.dsp.exec_cmd("${captureRegion} --take-window")),
              hl.bind("CTRL + RETURN", hl.dsp.exec_cmd("${captureRegion} --take-fullscreen")),
              hl.bind("TAB", hl.dsp.exec_cmd("${captureRegion} --select-window next")),
              hl.bind("CTRL + TAB", hl.dsp.exec_cmd("${captureRegion} --select-window prev")),
            }
            for _, direction in ipairs({ "left", "right", "up", "down" }) do
              table.insert(
                selection_binds,
                hl.bind(direction:upper(), hl.dsp.exec_cmd("${captureRegion} --select-window " .. direction))
              )
            end
          end
        end
      end)

      hl.on("layer.closed", function(layer)
        if layer.namespace == "selection" and selection_layers > 0 then
          selection_layers = selection_layers - 1
          if selection_layers == 0 then
            for _, keybind in ipairs(selection_binds) do
              keybind:unbind()
            end
            selection_binds = {}
          end
        end
      end)

      -- Screen recording. Same key toggles: press to pick a region/window/
      -- monitor and start, press again to stop, post-process and save.
      hl.bind("ALT + Print", hl.dsp.exec_cmd("${screenrecord}"))
      hl.bind("ALT + SHIFT + Print", hl.dsp.exec_cmd("${screenrecord} --fullscreen --with-desktop-audio"))
      hl.bind("ALT + CONTROL + Print", hl.dsp.exec_cmd("${screenrecord} --with-desktop-audio --with-microphone-audio"))

      -- Windows
      hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
      hl.bind(mod .. " + Q", hl.dsp.window.close())
      hl.bind(mod .. " + S", hl.dsp.layout("togglesplit"))
      hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mod .. " + G", hl.dsp.group.toggle())
      hl.bind(mod .. " + ALT + CONTROL + SHIFT + L", hl.dsp.exec_cmd("${layoutToggle}/bin/hypr-layout-toggle"))
      hl.bind(mod .. " + X", hl.dsp.group.lock_active({ action = "toggle" }))
      hl.bind(mod .. " + Tab", hl.dsp.group.next())
      hl.bind(mod .. " + SHIFT + Tab", hl.dsp.group.prev())

      -- Directional window management, vim keys
      local directions = { h = "left", l = "right", k = "up", j = "down" }
      for key, dir in pairs(directions) do
        hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }))
        hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = dir }))
        hl.bind(mod .. " + CONTROL + " .. key, hl.dsp.group.move_window({ direction = dir }))
        hl.bind("ALT + CONTROL + " .. key, hl.dsp.window.move({ direction = dir }))
        hl.bind(mod .. " + ALT + " .. key, hl.dsp.workspace.move({ monitor = dir }))
      end

      -- Workspaces: mod + [0-9] to focus, mod + SHIFT + [0-9] to send the window
      for i = 1, 10 do
        local key = i % 10 -- 10 maps to key 0
        hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, silent = true }))
      end

      hl.bind(mod .. " + u", hl.dsp.workspace.toggle_special())
      hl.bind(mod .. " + SHIFT + u", hl.dsp.window.move({ workspace = "special" }))

      -- Monitors. Toggle the laptop panel off, or back on below the external.
      hl.bind(mod .. " + F7", function()
        hl.monitor({ output = "${laptopMonitor}", disabled = true })
      end)
      hl.bind(mod .. " + SHIFT + F7", function()
        hl.monitor({
          output = "${laptopMonitor}",
          mode = "${laptopResolution}",
          position = "1280x2160",
          scale = ${toString laptopScale},
        })
      end)

      -- Media and brightness. ignore_mods so they fire with any modifier held.
      local mediaKeys = {
        { "XF86MonBrightnessUp", "${increaseBrightnessCommand}" },
        { "XF86MonBrightnessDown", "${decreaseBrightnessCommand}" },
        { "XF86AudioRaiseVolume", "${pkgs.pamixer}/bin/pamixer -i 5" },
        { "XF86AudioLowerVolume", "${pkgs.pamixer}/bin/pamixer -d 5" },
        { "XF86AudioMute", "${pkgs.pamixer}/bin/pamixer --toggle-mute" },
        { "XF86AudioMicMute", "${pkgs.pamixer}/bin/pamixer --default-source --toggle-mute" },
        { "XF86AudioNext", "playerctl next" },
        { "XF86AudioPrev", "playerctl previous" },
        { "XF86AudioPlay", "playerctl play-pause" },
        { "XF86AudioStop", "playerctl stop" },
      }
      for _, entry in ipairs(mediaKeys) do
        hl.bind(entry[1], hl.dsp.exec_cmd(entry[2]), { ignore_mods = true })
      end

      -- Resize the active window. NOTE: these keys are already taken by the
      -- move-workspace-to-monitor binds above, which win; kept to preserve the
      -- pre-migration config exactly.
      local resizeSteps = { h = { -20, 0 }, l = { 20, 0 }, k = { 0, -20 }, j = { 0, 20 } }
      for key, step in pairs(resizeSteps) do
        hl.bind(mod .. " + ALT + " .. key, hl.dsp.window.resize({ x = step[1], y = step[2], relative = true }), { repeating = true })
      end

      -- Mouse
      hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
    '';
  };
}
