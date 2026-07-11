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
      monitor = "eDP-1, highrr, auto, 1.25";
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
    nwg-displays
    hyprpolkitagent
    immich-go
    libnotify
    nix-prefetch
    nix-prefetch-scripts
    wireguard-tools # ad-hoc `wg-quick up/down` for the UDM WireGuard client
  ];

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

    security.sops.enable = true;
  };

  home.stateVersion = "24.11";
}
