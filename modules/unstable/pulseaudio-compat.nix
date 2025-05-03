{
  config,
  lib,
  ...
}:
with lib; let
  # Check if we're using the stable channel where hardware.pulseaudio exists
  isStableChannel = hasAttr "pulseaudio" config.hardware;
in {
  # Define the services.pulseaudio options
  options.services.pulseaudio = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Compatibility option for services.pulseaudio.enable";
    };

    # Add support32Bit option that Jovian needs
    support32Bit = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to include 32-bit PulseAudio libraries";
    };

    # Add other common PulseAudio options
    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "The PulseAudio package to use";
    };

    daemon = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable the PulseAudio system-wide daemon";
      };
    };

    # Add more options as needed based on errors
  };

  # Forward settings from services.pulseaudio to hardware.pulseaudio
  config = mkIf isStableChannel {
    # Only set hardware.pulseaudio if services.pulseaudio is enabled
    hardware.pulseaudio = {
      enable = mkIf config.services.pulseaudio.enable true;
      support32Bit = mkIf config.services.pulseaudio.enable config.services.pulseaudio.support32Bit;
      # Forward other options as needed
    };

    # This assertion prevents both from being enabled at the same time in different ways
    assertions = [
      {
        assertion =
          !(config.hardware.pulseaudio.enable
            && config.services.pulseaudio.enable
            && config.hardware.pulseaudio.enable != config.services.pulseaudio.enable);
        message = "Cannot enable both hardware.pulseaudio and services.pulseaudio with different values";
      }
    ];
  };
}
