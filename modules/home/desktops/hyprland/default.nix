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
  cfg = config.desktops.hyprland;
in {
  imports = lib.snowfall.fs.get-non-default-nix-files ./.;

  options.desktops.hyprland = {
    enable = mkEnableOption "Enable hyprland window manager";
    execOnceExtras = mkOpt (listOf str) [] "Extra programs to exec once";
  };

  config = mkIf cfg.enable {
    # nix.settings = {
    #   trusted-substituters = ["https://hyprland.cachix.org"];
    #   trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    # };

    # TODO: decouple this from hyprland
    guis.common.enable = true;

    desktops.addons = {
      rofi.enable = true;
      swaync.enable = true;
      waybar.enable = true;
      wlogout.enable = true;

      pyprland.enable = true;
      hyprpaper.enable = true;
      hyprlock.enable = true;
      hypridle.enable = true;
    };

    # Fixes tray icons: https://github.com/nix-community/home-manager/issues/2064#issuecomment-887300055
    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = ["graphical-session-pre.target"];
      };
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      QT_QPA_PLATFORM = "wayland;xcb";
      LIBSEAT_BACKEND = "logind";
    };

    home.packages = with pkgs; [
      mplayer
      brightnessctl
      xdg-utils
      wl-clipboard
      clipse
      pamixer
      playerctl

      grimblast
      slurp
      sway-contrib.grimshot
      satty
    ];
  };
}
