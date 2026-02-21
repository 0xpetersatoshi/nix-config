{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
with types; let
  cfg = config.guis.common;

  # HACK: electron apps in hyprland need special flags for proper Wayland support
  # and password storage configuration. Cider is an Electron app that needs:
  # 1. Ozone platform flags for native Wayland rendering
  # 2. Password store flag to work with kwallet6 on Hyprland
  cider-wrapped = pkgs.symlinkJoin {
    name = "cider";
    paths = [pkgs.cider];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/cider \
        --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland --password-store=kwallet6"
    '';
  };
in {
  options.guis.common = {
    enable = mkEnableOption "Enable common guis";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cava # audio visualizer
      cider-wrapped # apple music player
      foliate
      keymapp
      wiremix
      spotify
      vlc
    ];
  };
}
