{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.desktops.addons.hyprpanel;
in {
  options.desktops.addons.hyprpanel = {
    enable = mkEnableOption "Enable hyprpanel";
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
  };
}
