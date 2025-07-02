{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.desktops.addons.waybar;
in {
  options.desktops.addons.waybar = {
    enable = mkEnableOption "Enable waybar";
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          margin = "10 10 0 10";
          modules-left = [
            "hyprland/workspaces"
          ];
          modules-center = [
            "custom/notification"
            "clock"
            # "idle_inhibitor"
          ];
          modules-right = [
            # "backlight"
            # "battery"
            "tray"
            "pulseaudio"
            "bluetooth"
            "network"
          ];
          "hyprland/workspaces" = {
            format = "{name}";
            sort-by-number = true;
            active-only = false;
            show-special = false;
            persistent-workspaces = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
            };
            on-click = "activate";
          };
          clock = {
            format = "󰃰 {:%a, %b %d, %I:%M %p}";
            interval = 1;
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "year";
              "mode-mon-col" = 3;
              "weeks-pos" = "right";
              "on-scroll" = 1;
              "on-click-right" = "mode";
              format = {
                months = "<span color='#${config.lib.stylix.colors.base0E}'><b>{}</b></span>";
                days = "<span color='#${config.lib.stylix.colors.base0D}'><b>{}</b></span>";
                weeks = "<span color='#${config.lib.stylix.colors.base0C}'><b>W{}</b></span>";
                weekdays = "<span color='#${config.lib.stylix.colors.base0A}'><b>{}</b></span>";
                today = "<span color='#${config.lib.stylix.colors.base08}'><b><u>{}</u></b></span>";
              };
            };
          };
          "custom/notification" = {
            tooltip = false;
            format = "{} {icon}";
            "format-icons" = {
              notification = "󱅫";
              none = "";
              "dnd-notification" = " ";
              "dnd-none" = "󰂛";
              "inhibited-notification" = " ";
              "inhibited-none" = "";
              "dnd-inhibited-notification" = " ";
              "dnd-inhibited-none" = " ";
            };
            "return-type" = "json";
            "exec-if" = "which swaync-client";
            exec = "swaync-client -swb";
            "on-click" = "sleep 0.1 && swaync-client -t -sw";
            "on-click-right" = "sleep 0.1 && swaync-client -d -sw";
            escape = true;
          };
          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = "  ";
              deactivated = "  ";
            };
          };
          backlight = {
            format = " {percent}%";
          };
          battery = {
            states = {
              good = 80;
              warning = 50;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-alt = "{time}";
            format-charging = "  {capacity}%";
            format-icons = ["󰁻 " "󰁽 " "󰁿 " "󰂁 " "󰂂 "];
          };

          network = {
            interval = 1;
            format = "󰈀 {ifname}";
            format-wifi = " {essid} ({signalStrength}%)";
            format-ethernet = "󰈀 {ifname}";
            format-disconnected = "󱚵 Disconnected";
            tooltip-format = ''
              {ifname}
              IP: {ipaddr}
              Up: {bandwidthUpBits}
              Down: {bandwidthDownBits}
            '';
            tooltip-format-wifi = ''
              {ifname} @ {essid}
              IP: {ipaddr}
              Strength: {signalStrength}%
              Freq: {frequency}MHz
              Up: {bandwidthUpBits}
              Down: {bandwidthDownBits}
            '';
            tooltip-format-ethernet = ''
              {ifname}
              IP: {ipaddr}
              Up: {bandwidthUpBits}
              Down: {bandwidthDownBits}
            '';
          };

          pulseaudio = {
            scroll-step = 2;
            format = "{icon} {volume}%";
            format-bluetooth = "{icon} {volume}%";
            format-bluetooth-muted = "󰝟 Muted";
            format-muted = "󰝟 Muted";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "󰋋";
              hands-free = "";
              headset = "󰋋";
              phone = "󰏲";
              portable = "";
              car = "󰄋";
              default = ["" "" ""];
            };
            on-click = "pavucontrol";
          };

          bluetooth = {
            format = "󰂯 {status}";
            format-connected = "󰂯 {device_alias}";
            format-connected-battery = "󰂯 {device_alias} ({device_battery_percentage}%)";
            format-disabled = "󰂲";
            format-off = "󰂲";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
            on-click = "blueman-manager";
          };

          tray = {
            icon-size = 21;
            spacing = 10;
          };
        }
      ];

      style = ''
        /* Stylix base16 colors */
        @define-color base00 #${config.lib.stylix.colors.base00};
        @define-color base01 #${config.lib.stylix.colors.base01};
        @define-color base02 #${config.lib.stylix.colors.base02};
        @define-color base03 #${config.lib.stylix.colors.base03};
        @define-color base04 #${config.lib.stylix.colors.base04};
        @define-color base05 #${config.lib.stylix.colors.base05};
        @define-color base06 #${config.lib.stylix.colors.base06};
        @define-color base07 #${config.lib.stylix.colors.base07};
        @define-color base08 #${config.lib.stylix.colors.base08};
        @define-color base09 #${config.lib.stylix.colors.base09};
        @define-color base0A #${config.lib.stylix.colors.base0A};
        @define-color base0B #${config.lib.stylix.colors.base0B};
        @define-color base0C #${config.lib.stylix.colors.base0C};
        @define-color base0D #${config.lib.stylix.colors.base0D};
        @define-color base0E #${config.lib.stylix.colors.base0E};
        @define-color base0F #${config.lib.stylix.colors.base0F};

        ${builtins.readFile ./styles.css}
      '';
    };
  };
}
