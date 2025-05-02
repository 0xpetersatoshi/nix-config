{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.${namespace}.asus;
in {
  options.hardware.${namespace}.asus = {
    enable = mkEnableOption "Enable ASUS-specific hardware configurations";
    model = mkOption {
      type = types.str;
      default = "zenbook";
      description = "ASUS model type";
    };
  };

  config = mkIf cfg.enable {
    # ACPI parameters for better hardware compatibility
    boot.kernelParams = [
      "acpi_osi=!"
      "acpi_osi=\"Windows 2020\""
    ];

    # Unblock Bluetooth service
    systemd.services.asus-bluetooth-unblock = {
      description = "Unblock ASUS Bluetooth";
      wantedBy = ["multi-user.target"];
      after = ["bluetooth.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
        # Run this after a short delay to ensure Bluetooth service is fully initialized
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      };
    };

    # Add udev rules to unblock Bluetooth on device detection
    services.udev.extraRules = ''
      # Unblock Bluetooth by default
      SUBSYSTEM=="rfkill", ATTR{type}=="bluetooth", ATTR{state}="1"
    '';

    # Disable power saving for Wi-Fi which can cause issues
    boot.extraModprobeConfig = ''
      options iwlwifi power_save=0
      options iwlmvm power_scheme=1
    '';
  };
}
