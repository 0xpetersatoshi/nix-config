{
  config,
  pkgs,
  ...
}: {
  desktops = {
    hyprland = {
      enable = true;
      bar = "waybar";
      # Nvidia GPU
      drmDevices = "/dev/dri/by-path/pci-0000:01:00.0-card";
    };

    addons = {
      hyprpanel = {
        wallpaperPath = ../../../wallpaper/ultrawide/sci_fi_architecture_building_beach-wallpaper-3440x1440.jpg;
        matugen = {
          schemeType = "rainbow";
          variation = "standard_2";
        };
        layouts = {
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
  };

  guis = {
    media.enable = true;
    web3 = {
      wallets.enable = true;
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

  roles = {
    common.enable = true;
    desktop.enable = true;
    development.enable = true;
    gaming = {
      enable = false;
    };
  };

  igloo = {
    user = {
      enable = true;
      inherit (config.snowfallorg.user) name;
    };

    security.sops.enable = true;

    theme.stylix.image = ../../../wallpaper/ultrawide/sci_fi_architecture_building_beach-wallpaper-3440x1440.jpg;
  };

  home.stateVersion = "24.11";
}
