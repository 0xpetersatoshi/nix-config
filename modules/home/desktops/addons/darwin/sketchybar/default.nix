{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.desktops.addons.darwin.sketchybar;
in {
  options.desktops.addons.darwin.sketchybar = {
    enable = mkEnableOption "Enable sketchybar configuration";
  };

  config = mkIf cfg.enable {
    xdg.configFile."sketchybar" = {
      source = ./sketchybar;
      recursive = true;
      executable = true;
    };

    home.packages = with pkgs; [
      jankyborders
      sketchybar
      sketchybar-app-font
    ];
  };
}
