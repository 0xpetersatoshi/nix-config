{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.audio;
in {
  options.hardware.audio = with types; {
    enable = mkBoolOpt false "Enable or disable hardware audio support";
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
      wireplumber.enable = true;
      jack.enable = true;
    };
    programs.noisetorch.enable = true;

    services.udev.packages = [
    ];

    environment.systemPackages = with pkgs; [
      alsa-ucm-conf
      pulseaudioFull
      pulsemixer
    ];
  };
}
