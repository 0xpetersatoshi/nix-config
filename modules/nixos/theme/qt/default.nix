{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.theme.qt;
in {
  options.${namespace}.theme.qt = with types; {
    enable = lib.mkEnableOption "customizing qt and apply themes";

    theme = {
      name = mkOpt str "Catppuccin-Macchiato-Blue" "The name of the kvantum theme to apply.";
      package = mkOpt package (pkgs.catppuccin-kvantum.override {
        accent = "blue";
        variant = "macchiato";
      }) "The package to use for the theme.";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.theme.package];
    };

    qt = {
      enable = true;

      platformTheme = lib.mkDefault "kde6";
      style = lib.mkDefault "kvantum";
    };
  };
}
