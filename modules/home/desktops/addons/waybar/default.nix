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
    isLaptop = mkOption {
      type = types.bool;
      default = false;
      description = "Whether the device is a laptop (enables battery module)";
    };
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
            "custom/menu"
            "hyprland/workspaces"
          ];

          modules-center = [
            "custom/notification"
            "clock"
            "idle_inhibitor"
            "mpris"
          ];

          modules-right = lib.flatten [
            "cpu"
            "memory"
            # "backlight"
            (lib.optional cfg.isLaptop "battery")
            "tray"
            "pulseaudio"
            "bluetooth"
            "network"
          ];

          "custom/menu" = {
            format = "";
            on-click = "wlogout --column-spacing 50 --row-spacing 50";
            on-click-right = "hyprlock";
            tooltip-format = "Left-click: wlogout\nRight-click: hyprlock";
          };

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
            format = "{icon} {}";
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
              activated = "";
              deactivated = "";
            };
          };

          mpris = {
            format = "{player_icon} {dynamic}";
            format-paused = "{status_icon} <i>{dynamic}</i>";
            max-length = 40;
            interval = 3;
            dynamic-order = ["title" "artist"];
            dynamic-importance-order = ["title" "artist"];
            dynamic-len = 40;
            dynamic-separator = " • ";
            ellipsis = "...";
            player-icons = {
              default = "▶";
              mpv = "🎵";
              spotify = "󰓇";
              firefox = "󱉺";
            };
            status-icons = {
              paused = "󰏤";
            };
            on-click = "playerctl play-pause";
            on-click-right = "playerctl next";
            on-click-middle = "playerctl previous";
            on-scroll-up = "playerctl volume 0.05+";
            on-scroll-down = "playerctl volume 0.05-";
            tooltip = true;
            tooltip-format = ''
              {player} ({status})
              Title: {title}
              Artist: {artist}
              Album: {album}

              Click: Play/Pause
              Right-click: Next
              Middle-click: Previous
              Scroll: Volume control
            '';
          };

          backlight = {
            format = " {percent}%";
          };

          battery = {
            states = {
              good = 75;
              warning = 45;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-alt = "{time}";
            format-charging = "󰂄 {capacity}%";
            format-icons = ["󰁻" "󰁽" "󰁿" "󰂁" "󰂂"];
          };

          network = {
            interval = 1;
            format = "󰈀 {ifname}";
            format-wifi = "󰖩 {essid}";
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
            on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
            on-click-middle = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            tooltip = true;
            tooltip-format = ''
              Volume: {volume}%
              Device: {desc}

              Click: Open audio settings
              Right-click: Toggle mute
              Middle-click: Toggle mic mute
            '';
          };

          cpu = {
            format = "󰍛 {usage}%";
            interval = 2;
            tooltip = true;
            tooltip-format = ''
              CPU Usage: {usage}%
              Load Average: {load}
            '';
          };

          memory = {
            format = " {percentage}%";
            interval = 5;
            tooltip = true;
            tooltip-format = ''
              RAM: {used:0.1f}GiB / {total:0.1f}GiB ({percentage}%)
              Available: {avail:0.1f}GiB
              Swap: {swapUsed:0.1f}GiB / {swapTotal:0.1f}GiB
            '';
          };

          bluetooth = {
            format = "󰂯 {status}";
            format-connected = "󰂯 {device_alias}";
            format-connected-battery = "󰂯 {device_alias} ({device_battery_percentage}%)";
            format-disabled = "󰂲";
            format-off = "󰂲";
            tooltip-format = ''
              controller: {controller_alias}
              controller address: {controller_address}
              connections: {num_connections} connected
            '';
            tooltip-format-connected = ''
              controller: {controller_alias}
              address: {controller_address}
              connections: {num_connections} connected
              ==========================
              device: {device_enumerate}
            '';
            tooltip-format-enumerate-connected = ''
              {device_alias}
              address: {device_address}
            '';
            tooltip-format-enumerate-connected-battery = ''
              {device_alias}
              address: {device_address}
              battery: {device_battery_percentage}%
            '';
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
