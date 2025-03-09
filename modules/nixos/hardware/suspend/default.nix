{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.suspend;
in {
  options.hardware.suspend = with types; {
    enable = mkBoolOpt false "Enable special suspend handling for problematic hardware";
    hasAmdCpu = mkBoolOpt false "Whether or not the system has an AMD CPU";
    hasNvidiaGpu = mkBoolOpt false "Whether or not the system has an Nvidia GPU";
  };

  config = mkIf cfg.enable {
    # Add the kernel parameters
    boot.kernelParams = with pkgs.lib;
      [
        "acpi_osi=Linux"
        "acpi_osi=\"!Windows 2015\""
        "nmi_watchdog=0"
        "irqpoll"
      ]
      ++ (optionals cfg.hasAmdCpu [
        "amd_iommu=on"
        "iommu=pt"
        "processor.max_cstate=5"
        "idle=nomwait"
        "acpi.no_ec_wakeup=1"
        "acpi.ec_no_wakeup=1"
      ])
      ++ (optionals cfg.hasNvidiaGpu [
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
        "nvidia.NVreg_TemporaryFilePath=/var/tmp"
      ]);

    # Add a systemd service to handle APIC issues
    systemd.services.fix-apic-suspend = {
      description = "Fix APIC issues before suspend";
      wantedBy = ["sleep.target"];
      before = ["sleep.target"];
      script = ''
        # Disable local APIC
        echo 0 > /sys/module/processor/parameters/max_cstate || true

        # Disable all wake sources except power button
        for device in $(cat /proc/acpi/wakeup | grep "*enabled" | awk '{print $1}'); do
          if [[ "$device" != "PWRB" ]]; then
            echo "$device" > /proc/acpi/wakeup
          fi
        done
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
      };
    };

    # Modify logind for better suspend behavior
    services.logind.extraConfig = ''
      HandleSuspendKey=suspend
      SuspendMode=deep
      SuspendState=mem
    '';
  };
}
