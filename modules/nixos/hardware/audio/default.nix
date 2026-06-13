{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.${namespace}.audio;
in {
  options.hardware.${namespace}.audio = with types; {
    enable = mkBoolOpt false "Enable or disable hardware audio support";
    hdmiKeepalive = mkBoolOpt false "Stream silence into the default sink to keep an HDMI audio link from sleeping (prevents the first ~300-800ms of short sounds from being clipped)";
  };

  config = mkIf cfg.enable {
    # services.pulseaudio.enable = false;
    # NOTE: after experiencing some audio issues with select browsers
    # this issue thread helped solve the issue: https://github.com/NixOS/nixpkgs/issues/271847#issuecomment-1894300156
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      wireplumber = {
        enable = true;
        # Disable idle suspend on audio sinks so short event sounds
        # (notifications, pw-play of .oga files) don't get clipped while
        # the sink resumes from suspend.
        extraConfig."51-disable-suspend" = {
          "monitor.alsa.rules" = [
            {
              matches = [{"node.name" = "~alsa_output.*";}];
              actions = {
                update-props = {
                  "session.suspend-timeout-seconds" = 0;
                };
              };
            }
          ];
        };
      };
      jack.enable = true;
    };
    systemd.user.services.pipewire-keepalive = mkIf cfg.hdmiKeepalive {
      description = "Stream silence into the default PipeWire sink to keep HDMI awake";
      after = ["pipewire.service"];
      bindsTo = ["pipewire.service"];
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = "${pkgs.pipewire}/bin/pw-cat --playback --rate 48000 --channels 2 --format s16 /dev/zero";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    programs.noisetorch.enable = true;

    services.udev.packages = [
    ];

    environment = {
      systemPackages = with pkgs; [
        alsa-tools
        alsa-utils
        # pulseaudioFull
        pulsemixer
      ];
    };
  };
}
