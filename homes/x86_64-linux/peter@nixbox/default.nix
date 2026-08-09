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
    digikam
    exiftool
    lutris # runs ON1 Photo Raw via GE-Proton; see notes
    protonup-qt # installs GE-Proton runners for lutris
    nwg-displays
    hyprpolkitagent
    immich-go
    libnotify
    nix-prefetch
    nix-prefetch-scripts
  ];

  cloud.aws = {
    enable = true;
    secretsFile = ../../../secrets/aws.yaml;
  };

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
