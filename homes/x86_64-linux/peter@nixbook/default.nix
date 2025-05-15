{pkgs, ...}: {
  desktops = {
    hyprland = {
      enable = true;
      hasLunarLakeCPU = true;
      monitor = "eDP-1, highrr, auto, 1.25";
      drmDevices = "/dev/dri/by-path/pci-0000:00:02.0-card";
      execOnceExtras = [
        "${pkgs.libinput-gestures}/bin/libinput-gestures &"
      ];
    };

    addons = {
      hyprpanel = {
        wallpaperPath = ../../../wallpaper/standard/astronaut-5-2912x1632.jpg;
        overwrite = false;
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

  roles = {
    common.enable = true;
    desktop.enable = true;
    development.enable = true;
  };

  igloo.user = {
    enable = true;
    name = "peter";
  };

  home.stateVersion = "24.11";
}
