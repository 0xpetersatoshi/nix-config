{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.desktops.addons.walker;
in {
  options.desktops.addons.walker = {
    enable = mkEnableOption "Enable walker application launcher";
  };

  config = mkIf cfg.enable {
    programs.walker = {
      enable = true;
      runAsService = true;

      config = {
        theme = "stylix";
      };

      themes.stylix = {
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

          ${builtins.readFile ./style.css}
        '';
      };
    };
  };
}
