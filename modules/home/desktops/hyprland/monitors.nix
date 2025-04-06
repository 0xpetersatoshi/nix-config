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
            if grep -q open /proc/acpi/button/lid/LID0/state; then
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

    wayland.windowManager.hyprland.settings = {
      # Monitor configuration
      monitor = mkIf cfg.multiMonitor.enable [
        # Default configuration for single monitor mode
        "${cfg.multiMonitor.laptopMonitor},${cfg.multiMonitor.laptopResolution},0x0,${toString cfg.multiMonitor.laptopScale}"
        "${cfg.multiMonitor.externalMonitor},${cfg.multiMonitor.externalResolution},0x0,${toString cfg.multiMonitor.externalScale}"
        # Position for dual monitor mode - will be overridden by the script
      ];

      # Default workspaces
      workspace = [
        "1,monitor:${cfg.multiMonitor.externalMonitor},default:true"
        "2,monitor:${cfg.multiMonitor.externalMonitor}"
        "3,monitor:${cfg.multiMonitor.externalMonitor}"
        "4,monitor:${cfg.multiMonitor.externalMonitor}"
        "5,monitor:${cfg.multiMonitor.externalMonitor}"
        "6,monitor:${cfg.multiMonitor.laptopMonitor},default:true"
        "7,monitor:${cfg.multiMonitor.laptopMonitor}"
        "8,monitor:${cfg.multiMonitor.laptopMonitor}"
        "9,monitor:${cfg.multiMonitor.laptopMonitor}"
        "10,monitor:${cfg.multiMonitor.laptopMonitor}"
      ];

      # Add to exec-once
      exec-once = mkIf cfg.multiMonitor.enable [
        "${handleMonitorsScript}/bin/handle-monitors"
      ];

      # Add hotplug event handlers
      bindl = mkIf cfg.multiMonitor.enable [
        ",monitor:disconnect:${cfg.multiMonitor.externalMonitor},exec,${handleMonitorsScript}/bin/handle-monitors"
        ",monitor:connect:${cfg.multiMonitor.externalMonitor},exec,${handleMonitorsScript}/bin/handle-monitors"
        ",switch:Lid Switch,exec,${handleMonitorsScript}/bin/handle-monitors"
      ];
    };
  };
}
