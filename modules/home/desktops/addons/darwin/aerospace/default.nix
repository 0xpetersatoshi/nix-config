{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.desktops.addons.darwin.aerospace;
in {
  options.desktops.addons.darwin.aerospace = {
    enable = mkEnableOption "Enable aerospace configuration";
  };

  config = mkIf cfg.enable {
    xdg.configFile."aerospace/aerospace.toml".source = ./aerospace.toml;
    home.packages = with pkgs; [
      aerospace
    ];
  };
}
