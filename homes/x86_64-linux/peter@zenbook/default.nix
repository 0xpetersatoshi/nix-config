{
  config,
  lib,
  pkgs,
  ...
}: {
  desktops = {
    hyprland = {
      enable = true;
      bar = "dms";
      hasLunarLakeCPU = true;
      monitor = {
        output = "eDP-1";
        mode = "highrr";
        position = "auto";
        scale = 1.25;
      };
      multiMonitor = {
        enable = false;
        laptopScale = 1.0; # Override the default 1.5 scale
      };
      execOnceExtras = [
        "${pkgs.libinput-gestures}/bin/libinput-gestures &"
      ];
    };

    addons = {
      dms.isLaptop = true;
    };
  };

  guis = {
    appimage.superbacked.enable = pkgs.stdenv.isLinux;
    media.enable = true;
    web3 = {
      wallets.enable = true;
    };
  };

  home.packages = with pkgs; [
    digikam
    exiftool
    nwg-displays
    hyprpolkitagent
    immich-go
    libnotify
    nix-prefetch
    nix-prefetch-scripts
    wireguard-tools # ad-hoc `wg-quick up/down` for the home WireGuard client
  ];

  cloud.aws = {
    enable = true;
    secretsFile = ../../../secrets/aws.yaml;
  };

  # Ad-hoc WireGuard client for the UniFi Dream Machine. Nothing runs at boot;
  # bring it up on demand with `wg-home-up` / `wg-home-down`.
  #
  # The conf lives age-encrypted in modules/home/secrets.yaml (key: wireguard-home-conf)
  # and is decrypted at login to tmpfs at $XDG_RUNTIME_DIR/wg-home.conf (mode 0400).
  # The plaintext key therefore never persists on disk.
  sops.secrets.wireguard-home-conf = lib.mkIf config.igloo.security.sops.enable {
    path = "%r/wg-home.conf"; # %r = $XDG_RUNTIME_DIR (memory-backed, per-user)
  };

  sops.secrets.wireguard-home-conf-local = lib.mkIf config.igloo.security.sops.enable {
    path = "%r/wg-home-local.conf"; # %r = $XDG_RUNTIME_DIR (memory-backed, per-user)
  };

  home.shellAliases = {
    wg-home-up = ''sudo wg-quick up "$XDG_RUNTIME_DIR/wg-home.conf"'';
    wg-home-down = ''sudo wg-quick down "$XDG_RUNTIME_DIR/wg-home.conf"'';
    wg-home-up-local = ''sudo wg-quick up "$XDG_RUNTIME_DIR/wg-home-local.conf"'';
    wg-home-down-local = ''sudo wg-quick down "$XDG_RUNTIME_DIR/wg-home-local.conf"'';
  };

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

    security.sops.enable = true;
  };

  home.stateVersion = "24.11";
}
