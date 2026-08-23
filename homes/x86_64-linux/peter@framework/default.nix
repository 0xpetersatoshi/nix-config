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
      # 2880x1920 3:2 panel, 30-120Hz
      monitor = {
        output = "eDP-1";
        mode = "highrr";
        position = "auto";
        scale = 1.5;
      };
      multiMonitor = {
        enable = false;
        laptopScale = 1.5;
      };
      execOnceExtras = [
        "${pkgs.libinput-gestures}/bin/libinput-gestures &"
      ];
    };

    addons = {
      dms.isLaptop = true;
    };
  };

  # DMS probes for the fingerprint reader once, when the shell starts, and never
  # re-probes on its own: if `fprintd-list` is slow or fprintd is not up yet at
  # login, the lock screen silently runs without the reader for the whole
  # session (password only) until DMS is restarted. The reader is permanent
  # hardware here, so skip the probe and let DMS's fprintd PAM context -- which
  # already retries with backoff -- be the thing that decides.
  systemd.user.services.dms.Service.Environment = ["DMS_FORCE_FPRINT_AVAILABLE=1"];

  guis = {
    appimage.superbacked.enable = pkgs.stdenv.isLinux;
    media.enable = true;
    web3 = {
      wallets.enable = true;
    };
  };

  home.packages = with pkgs; [
    digikam
    nwg-displays
    hyprpolkitagent
    immich-go
    libnotify
    nix-prefetch
    nix-prefetch-scripts
    wireguard-tools # ad-hoc `wg-quick up/down` for the UDM WireGuard client
  ];

  cloud.aws = {
    enable = true;
    secretsFile = ../../../secrets/aws.yaml;
  };

  # Ad-hoc WireGuard client for the UniFi Dream Machine. Nothing runs at boot;
  # bring it up on demand with `wg-udm-up` / `wg-udm-down`.
  #
  # The conf lives age-encrypted in modules/home/secrets.yaml (key: wireguard-udm-conf)
  # and is decrypted at login to tmpfs at $XDG_RUNTIME_DIR/wg-udm.conf (mode 0400).
  # The plaintext key therefore never persists on disk.
  sops.secrets.wireguard-udm-conf = lib.mkIf config.igloo.security.sops.enable {
    path = "%r/wg-udm.conf"; # %r = $XDG_RUNTIME_DIR (memory-backed, per-user)
  };

  sops.secrets.wireguard-udm-conf-local = lib.mkIf config.igloo.security.sops.enable {
    path = "%r/wg-udm-local.conf"; # %r = $XDG_RUNTIME_DIR (memory-backed, per-user)
  };

  home.shellAliases = {
    wg-udm-up = ''sudo wg-quick up "$XDG_RUNTIME_DIR/wg-udm.conf"'';
    wg-udm-down = ''sudo wg-quick down "$XDG_RUNTIME_DIR/wg-udm.conf"'';
    wg-udm-up-local = ''sudo wg-quick up "$XDG_RUNTIME_DIR/wg-udm-local.conf"'';
    wg-udm-down-local = ''sudo wg-quick down "$XDG_RUNTIME_DIR/wg-udm-local.conf"'';
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
