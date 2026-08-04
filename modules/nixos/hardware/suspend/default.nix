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
    hasMlx4Nic = mkBoolOpt false "Whether or not the system has a Mellanox ConnectX-3 (mlx4) NIC";
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

    # The mlx4 driver doesn't restore ConnectX-3 firmware/PHY state properly after
    # S3 resume: the SFP+ link flaps up/down every ~3s for 60-90s before stabilizing,
    # leaving the machine without connectivity. Fully unloading the modules before
    # sleep and reloading them on resume forces a clean re-init, bringing the link
    # up within seconds.
    systemd.services.mlx4-unload-before-sleep = mkIf cfg.hasMlx4Nic {
      description = "Unload mlx4 modules before suspend";
      wantedBy = ["sleep.target"];
      before = ["sleep.target"];
      script = ''
        ${pkgs.kmod}/bin/modprobe -r mlx4_en mlx4_ib mlx4_core || true
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
      };
    };

    systemd.services.mlx4-reload-after-resume = mkIf cfg.hasMlx4Nic {
      description = "Reload mlx4 modules after resume";
      wantedBy = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
      after = ["systemd-suspend.service" "systemd-hibernate.service" "systemd-hybrid-sleep.service"];
      script = ''
        ${pkgs.kmod}/bin/modprobe mlx4_core
        ${pkgs.kmod}/bin/modprobe mlx4_en
        ${pkgs.kmod}/bin/modprobe mlx4_ib || true

        # The SFP+ link flaps up/down for 15-80s of link training after the card
        # powers back on. networkd's DHCP retries back off exponentially during
        # the flapping, adding another ~10s of dead air once the link finally
        # holds. Wait for the carrier to stay up for 4 consecutive seconds, then
        # reconfigure the link so DHCP restarts with fresh state.
        stable=0
        for _ in $(seq 1 120); do
          # Re-resolve the interface name every iteration: right after modprobe
          # the device briefly appears as eth0 before udev renames it, and a
          # name captured too early points at a path that no longer exists.
          iface=$(basename "$(ls -d /sys/bus/pci/drivers/mlx4_core/*/net/* 2>/dev/null | head -n1)" 2>/dev/null || true)
          if [ -n "$iface" ] && [ "$(cat /sys/class/net/"$iface"/carrier 2>/dev/null)" = "1" ]; then
            stable=$((stable + 1))
          else
            stable=0
          fi
          if [ "$stable" -ge 4 ]; then
            # Skip the kick if DHCP already succeeded on its own
            if ! ${pkgs.iproute2}/bin/ip -4 addr show dev "$iface" | ${pkgs.gnugrep}/bin/grep -q inet; then
              echo "link on $iface held for 4s, restarting DHCP via networkctl reconfigure"
              ${pkgs.systemd}/bin/networkctl reconfigure "$iface" || true
            else
              echo "link on $iface held for 4s and already has an IPv4 address"
            fi
            break
          fi
          sleep 1
        done
        echo "done waiting for link (stable=$stable)"
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        TimeoutStartSec = 180;
      };
    };

    # Modify logind for better suspend behavior
    services.logind.settings.Login = {
      HandleSuspendKey = "suspend";
      SuspendMode = "deep";
      SuspendState = "mem";
    };
  };
}
