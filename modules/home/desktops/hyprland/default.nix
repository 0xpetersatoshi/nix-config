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
    hasLunarLakeCPU = mkBoolOpt false "Whether or not the system has an Intel Lunar Lake CPU";
    monitor = lib.mkOption {
      type = lib.types.str;
      default = ",preferred,auto,auto";
      description = "Hyprland monitor configuration settings";
    };
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
      wlogout.enable = true;

      pyprland.enable = true;
      hyprpanel.enable = true;
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
      hyprpanel
      mplayer
      brightnessctl
      wl-clipboard
      clipse
      pamixer
      playerctl
      light
      kdePackages.kcalc

      grimblast
      slurp
      sway-contrib.grimshot
      satty
    ];
  };
}
