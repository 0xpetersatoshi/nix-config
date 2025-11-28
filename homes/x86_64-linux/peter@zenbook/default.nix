{
  config,
  pkgs,
  ...
}: {
  desktops = {
    hyprland = {
      enable = true;
      bar = "waybar";
      hasLunarLakeCPU = true;
      monitor = "eDP-1, highrr, auto, 1.25";
      multiMonitor = {
        enable = false;
        laptopScale = 1.25; # Override the default 1.5 scale
      };
      execOnceExtras = [
        "${pkgs.libinput-gestures}/bin/libinput-gestures &"
      ];
    };

    addons = {
      hyprpanel = {
        wallpaperPath = ../../../wallpaper/standard/astronaut-5-2912x1632.jpg;
      };

      waybar.isLaptop = true;
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
    libnotify
    nix-prefetch
    nix-prefetch-scripts
  ];

  cli.programs.git.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFjoHku2U1i34uJWA6kODHU44QJCpQE7LHxYQgk382h";

  roles = {
    common.enable = true;
    desktop.enable = true;
    development.enable = true;
    gaming.enable = false;
  };

  igloo = {
    user = {
      enable = true;
      inherit (config.snowfallorg.user) name;
    };

    security.sops.enable = false;

    theme.stylix.image = ../../../wallpaper/standard/astronaut-5-2912x1632.jpg;
  };

  home.stateVersion = "24.11";
}
