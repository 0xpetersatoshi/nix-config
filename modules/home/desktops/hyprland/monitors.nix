{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.desktops.hyprland;

  # Create a script to handle monitor management
  handleMonitorsScript = pkgs.writeShellScriptBin "handle-monitors" ''
    #!/usr/bin/env bash

    handle_monitor_connect() {
        if [[ $(hyprctl monitors | grep "${cfg.multiMonitor.externalMonitor}") ]]; then
            # External monitor connected
            hyprctl keyword monitor "${cfg.multiMonitor.externalMonitor},${cfg.multiMonitor.externalResolution},0x0,${toString cfg.multiMonitor.externalScale}"

            # Check lid state
            if grep -q open /proc/acpi/button/lid/LID/state; then
                # Lid is open, position laptop below external monitor
                # Calculate the vertical position based on external resolution
                external_height=$(echo "${cfg.multiMonitor.externalResolution}" | sed 's/x/ /g' | awk '{print $2}' | cut -d '@' -f 1)
                hyprctl keyword monitor "${cfg.multiMonitor.laptopMonitor},${cfg.multiMonitor.laptopResolution},1280x$external_height,${toString cfg.multiMonitor.laptopScale}"
            else
                # Lid is closed, disable laptop monitor
                hyprctl keyword monitor "${cfg.multiMonitor.laptopMonitor},disable"
            fi

            # Move workspaces from laptop to external monitor if needed
            for i in {6..10}; do
                hyprctl dispatch workspace "$i"
                hyprctl dispatch moveworkspacetomonitor "$i" ${cfg.multiMonitor.externalMonitor}
            done
        else
            # External monitor disconnected, enable laptop monitor
            hyprctl keyword monitor "${cfg.multiMonitor.laptopMonitor},${cfg.multiMonitor.laptopResolution},0x0,${toString cfg.multiMonitor.laptopScale}"

            # Move all workspaces to laptop
            for i in {1..10}; do
                hyprctl dispatch workspace "$i"
                hyprctl dispatch moveworkspacetomonitor "$i" ${cfg.multiMonitor.laptopMonitor}
            done
        fi
    }

    handle_monitor_connect
  '';
in {
  config = mkIf (cfg.enable && cfg.multiMonitor.enable) {
    home.packages = [handleMonitorsScript];

    # Expose the script through the option
    desktops.hyprland.multiMonitor.monitorScript = handleMonitorsScript;

    wayland.windowManager.hyprland = {
      settings.monitor = [
        {
          output = cfg.multiMonitor.laptopMonitor;
          mode = cfg.multiMonitor.laptopResolution;
          position = "0x0";
          scale = cfg.multiMonitor.laptopScale;
        }
        {
          output = cfg.multiMonitor.externalMonitor;
          mode = cfg.multiMonitor.externalResolution;
          position = "0x0";
          scale = cfg.multiMonitor.externalScale;
        }
        # Positions above are the single-monitor defaults; handle-monitors
        # repositions them on hotplug.
      ];

      # Hotplug and lid handling. Monitor add/remove are real events now, which
      # replaces the old bindl ",monitor:connect:..." pseudo-binds.
      extraLuaFiles.monitors = ''
        local handleMonitors = "${handleMonitorsScript}/bin/handle-monitors"

        hl.on("hyprland.start", function() hl.exec_cmd(handleMonitors) end)
        hl.on("monitor.added", function() hl.exec_cmd(handleMonitors) end)
        hl.on("monitor.removed", function() hl.exec_cmd(handleMonitors) end)

        hl.bind("switch:Lid Switch", hl.dsp.exec_cmd(handleMonitors), { locked = true })
      '';
    };
  };
}
