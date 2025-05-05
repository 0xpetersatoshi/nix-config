{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.gaming;

  gs-script = pkgs.writeShellScriptBin "gs.sh" ''
    #!/usr/bin/env bash
    set -xeuo pipefail
    gamescopeArgs=(
        --adaptive-sync # VRR support
        --hdr-enabled
        --mangoapp # performance overlay
        --rt
        --steam
    )
    steamArgs=(
        -pipewire-dmabuf
        -tenfoot
    )
    mangoConfig=(
        cpu_temp
        gpu_temp
        ram
        vram
    )
    mangoVars=(
        MANGOHUD=1
        MANGOHUD_CONFIG="$(IFS=,; echo "''${mangoConfig[*]}")"
    )
    export "''${mangoVars[@]}"
    exec gamescope "''${gamescopeArgs[@]}" -- steam "''${steamArgs[@]}"
  '';
in {
  options.roles.gaming = with types; {
    enable = mkBoolOpt false "Enable the gaming suite";
    bootToSteamDeck = mkBoolOpt false "Enable booting into steam deck-like environment";
    gamescopeEnabled = mkBoolOpt true "Enable gamescope";
  };

  config = mkIf cfg.enable {
    hardware = {
      # xpadneo.enable = true;
      xone.enable = true;
    };

    services = {
      getty.autologinUser = mkIf cfg.bootToSteamDeck "${config.user.name}";
      ratbagd.enable = true;
    };

    programs = {
      gamemode.enable = true;
      gamescope = {
        enable = cfg.gamescopeEnabled;
        capSysNice = true;
      };
      steam = {
        enable = true;
        package = pkgs.steam.override {
          extraPkgs = p:
            with p; [
              mangohud
              gamemode
            ];
        };
        dedicatedServer.openFirewall = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        gamescopeSession.enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };
    };

    environment = {
      loginShellInit = mkIf cfg.bootToSteamDeck ''
        [[ "$(tty)" = "/dev/tty1" ]] && ${gs-script}/bin/gs.sh
      '';
      systemPackages = with pkgs; [
        winetricks
        wineWowPackages.waylandFull
      ];
    };
  };
}
