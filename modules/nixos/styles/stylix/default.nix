{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.styles.stylix;
in {
  options.styles.stylix = {
    enable = lib.mkEnableOption "Enable stylix";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-macchiato";
      description = "Stylix theme to apply";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";
    };
  };
}
