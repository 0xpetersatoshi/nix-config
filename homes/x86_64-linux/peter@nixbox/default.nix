{pkgs, ...}: {
  desktops = {
    hyprland = {
      enable = true;
    };

    addons.kde.enable = true;
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
  };

  igloo.user = {
    enable = true;
    name = "peter";
  };

  styles.stylix.wallpaperPath = ../../../wallpaper/ultrawide/sci_fi_architecture_building_beach-wallpaper-3440x1440.jpg;

  home.stateVersion = "24.11";
}
