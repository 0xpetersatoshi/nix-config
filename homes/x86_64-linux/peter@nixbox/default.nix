{pkgs, ...}: {
  desktops = {
    hyprland = {
      enable = true;
      execOnceExtras = [
        "${pkgs.networkmanagerapplet}/bin/nm-applet"
        "${pkgs.blueman}/bin/blueman-applet"
      ];
    };
  };

  home.packages = with pkgs; [
    nwg-displays
    hyprpolkitagent
    libsForQt5.dolphin
    libsForQt5.dolphin-plugins
    libsForQt5.kwallet
    libsForQt5.kwalletmanager
    libsForQt5.xwaylandvideobridge
    libnotify
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
  ];

  cli.programs.git.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFjoHku2U1i34uJWA6kODHU44QJCpQE7LHxYQgk382h";


  roles = {
    common.enable = true;
    development.enable = true;
  };

  igloo.user = {
    enable = true;
    name = "peter";
  };

  home.stateVersion = "24.11";
}
