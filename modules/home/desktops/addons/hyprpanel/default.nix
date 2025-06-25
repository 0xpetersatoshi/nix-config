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
    overwrite = mkBoolOpt true "Automatically deletes the config.json file before generating a new one to allow viewing live changes from GUI";

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
      # overwrite.enable = cfg.overwrite;
      systemd.enable = true;

      settings = {
        scalingPriority = "gdk";

        # Theme settings
        theme.bar.floating = true;
        theme.bar.transparent = false;
        theme.bar.opacity = 80;
        theme.bar.enableShadow = true;
        theme.bar.buttons.enableBorders = false;
        theme.bar.buttons.opacity = 100;
        theme.bar.buttons.background_opacity = 65;

        theme.font.size = "1rem";

        theme.matugen = true;
        theme.matugen_settings.scheme_type = "fruit-salad";
        theme.matugen_settings.variation = "standard_1";

        # Bar settings
        bar.launcher.autoDetectIcon = true;
        bar.workspaces.show_icons = false;
        bar.workspaces.show_numbered = true;
        bar.workspaces.numbered_active_indicator = "highlight";
        bar.workspaces.showWsIcons = false;
        bar.workspaces.showApplicationIcons = false;
        bar.workspaces.workspaceMask = false;
        bar.workspaces.ignored = "-98";

        # Wallpaper settings
        wallpaper.enable = true;
        wallpaper.image = "/home/${config.snowfallorg.user.name}/.local/share/hyprpanel/wallpapers/wallpaper.jpg";

        # Notifications
        notifications.position = "top right";

        # Menus
        menus.clock.time.hideSeconds = true;
        menus.dashboard.powermenu.avatar.image = "~/.local/share/hyprpanel/avatars/avatar.jpg";

        # Layout configuration
        bar.layouts = {
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
}
