{
  config,
  pkgs,
  ...
}: {
  desktops = {
    hyprland = {
      enable = true;
      bar = "dms";
      # AMD RX 9070 XT
      drmDevices = "/dev/dri/by-path/pci-0000:03:00.0-card";
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
  };

  home.stateVersion = "24.11";
}
