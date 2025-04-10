{
  pkgs,
  lib,
  ...
}: {
  desktops = {
    hyprland = {
      enable = true;
    };

    addons = {
      hyprpanel = {
        wallpaperPath = ../../../wallpaper/ultrawide/beautiful_winter_night_landscape-wallpaper-5120x2160.jpg;
      };
    };
  };

  home.packages = with pkgs; [
    nwg-displays
    hyprpolkitagent
    kdePackages.xwaylandvideobridge
    libnotify
    nix-prefetch
    nix-prefetch-scripts
  ];

  cli.programs.git.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFjoHku2U1i34uJWA6kODHU44QJCpQE7LHxYQgk382h";

  guis.browsers.msedge.enable = true;

  programs.hyprpanel.settings = lib.mkForce {
    theme.matugen_settings = {
      scheme_type = "rainbow";
      variation = "standard_2";
    };

    layout = {
      "bar.layouts" = {
        "0" = {
          left = ["dashboard" "workspaces" "windowtitle"];
          middle = ["clock"];
          right = [
            "volume"
            "network"
            "bluetooth"
            "systray"
            "media"
            "notifications"
          ];
        };
      };
    };
  };

  roles = {
    common.enable = true;
    desktop.enable = true;
    development.enable = true;
  };

  igloo.user = {
    enable = true;
    name = "peter";
  };

  styles.stylix = {
    theme = "tokyo-night-storm";
  };

  stylix.targets.hyprpaper.enable = lib.mkForce false;

  home.stateVersion = "24.11";
}
