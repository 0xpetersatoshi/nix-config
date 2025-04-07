{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
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
  };

  imports = [inputs.hyprpanel.homeManagerModules.hyprpanel];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gpu-screen-recorder
      hyprpanel
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
      hyprland.enable = false;
      overwrite.enable = true;

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
          matugen = true;
          matugen_settings = {
            scheme_type = "fruit-salad";
            variation = "standard_1";
          };
        };
        bar = {
          launcher.autoDetectIcon = true;
          workspaces = {
            show_icons = true;
            show_numbered = false;
            showWsIcons = false;
            showApplicationIcons = false;
            workspaceMask = false;
          };
        };
        wallpaper.image = "~/.local/share/hyprpanel/wallpapers/wallpaper.jpg";
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
        layout = {
          "bar.layouts" = {
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
        };
      };
    };
  };
}
