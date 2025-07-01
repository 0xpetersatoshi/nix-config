{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.desktops.addons.hyprpanel;
in {
  options.desktops.addons.hyprpanel = {
    enable = mkEnableOption "Enable hyprpanel";

    # Define these as proper options with types
    wallpaperPath = mkOption {
      type = types.path;
      default = ../../../../../wallpaper/standard/astronaut-1-3840x2160.jpg;
      description = "Path to the wallpaper image";
    };

    avatarPath = mkOption {
      type = types.path;
      default = ../../../../../profile/lazy-lion-pink.jpg;
      description = "Path to the avatar image";
    };

    matugen = {
      schemeType = mkOption {
        type = types.str;
        default = "fruit-salad";
        description = "Matugen color scheme type";
      };

      variation = mkOption {
        type = types.str;
        default = "standard_1";
        description = "Matugen color variation";
      };
    };

    layouts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            left = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Widgets to display on the left side of the bar";
            };
            middle = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Widgets to display in the middle of the bar";
            };
            right = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Widgets to display on the right side of the bar";
            };
          };
        }
      );
      default = {
        "0" = {
          left = ["dashboard" "workspaces" "windowtitle"];
          middle = ["clock"];
          right = [
            "volume"
            "network"
            "bluetooth"
            "battery"
            "systray"
            "media"
            "notifications"
          ];
        };
      };
      description = "Bar layout configuration per monitor";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gpu-screen-recorder
      hyprpicker
      matugen
      power-profiles-daemon
      pywal
      swww
    ];

    home.file.".local/share/hyprpanel/wallpapers/wallpaper.jpg".source = cfg.wallpaperPath;
    home.file.".local/share/hyprpanel/avatars/avatar.jpg".source = cfg.avatarPath;

    programs.hyprpanel = {
      enable = true;
      systemd.enable = true;

      settings = {
        scalingPriority = "gdk";

        theme = {
          bar = {
            floating = true;
            transparent = false;
            opacity = 80;
            enableShadow = true;
            buttons = {
              enableBorders = false;
              opacity = 100;
              background_opacity = 65;
            };
          };

          font.size = "1rem";

          matugen = true;
          matugen_settings = {
            scheme_type = cfg.matugen.schemeType;
            variation = cfg.matugen.variation;
          };
        };

        bar = {
          launcher.autoDetectIcon = true;
          layouts = cfg.layouts;
          workspaces = {
            show_icons = false;
            show_numbered = true;
            numbered_active_indicator = "highlight";
            showWsIcons = false;
            showApplicationIcons = false;
            workspaceMask = false;
            ignored = "-98";
          };
        };

        wallpaper = {
          enable = true;
          image = "/home/${config.snowfallorg.user.name}/.local/share/hyprpanel/wallpapers/wallpaper.jpg";
        };

        notifications.position = "top right";

        menus = {
          clock = {
            time = {
              hideSeconds = true;
            };
          };
          dashboard = {
            powermenu.avatar.image = "~/.local/share/hyprpanel/avatars/avatar.jpg";
          };
        };
      };
    };
  };
}
