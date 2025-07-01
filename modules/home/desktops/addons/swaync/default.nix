{
  config,
  lib,
  namespace,
  ...
}:
with lib; let
  cfg = config.desktops.addons.swaync;
  stylixCfg = config.${namespace}.theme.stylix;
in {
  options.desktops.addons.swaync = {
    enable = mkEnableOption "Enable sway notification center";
  };

  config = mkIf cfg.enable {
    services.swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";
        control-center-radius = 20;
        control-center-margin-top = 10;
        control-center-margin-bottom = 10;
        control-center-margin-right = 10;
        control-center-margin-left = 10;
        fit-to-screen = true;
        layer-shell = true;
        layer = "overlay";
        control-center-layer = "overlay";
        cssPriority = "user";
        notification-2fa-action = true;
        notification-inline-replies = false;
        notification-icon-size = 48;
        notification-body-image-height = 100;
        notification-body-image-width = 100;
        notification-window-width = 350;
        timeout = 6;
        timeout-low = 3;
        timeout-critical = 0;
        hide-on-action = true;

        widgets = [
          "inhibitors"
          "dnd"
          "mpris"
          "notifications"
        ];

        widget-config = {
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = "Clear All";
          };

          dnd = {
            text = "Do Not Disturb";
          };

          mpris = {
            image-size = 96;
            blur = true;
          };
        };
      };

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

        ${builtins.readFile ./swaync.css}
      '';
    };
  };
}
