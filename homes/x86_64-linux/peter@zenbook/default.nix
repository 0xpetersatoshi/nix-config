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
      execOnceExtras = [
        "${pkgs.libinput-gestures}/bin/libinput-gestures &"
      ];
    };

    addons = {
      hyprpanel = {
        wallpaperPath = ../../../wallpaper/standard/astronaut-5-2912x1632.jpg;
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

  roles = {
    common.enable = true;
    desktop.enable = true;
    development.enable = true;
    gaming.enable = true;
  };

  igloo = {
    user = {
      enable = true;
      inherit (config.snowfallorg.user) name;
    };

    security.sops.enable = true;

    theme.stylix.image = ../../../wallpaper/standard/astronaut-5-2912x1632.jpg;
  };

  home.stateVersion = "24.11";
}
