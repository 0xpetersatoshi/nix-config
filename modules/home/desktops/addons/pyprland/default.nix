{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.desktops.addons.pyprland;
in {
  options.desktops.addons.pyprland = {
    enable = mkEnableOption "Enable pyprland plugins for hyprland";
  };

  config = mkIf cfg.enable {
    xdg.configFile."pypr/config.toml".source = ./pyprland.toml;

    home = {
      packages = with pkgs; [pyprland];
    };
  };
}
