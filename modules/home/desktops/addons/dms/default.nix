{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.desktops.addons.dms;

  dmsBin = getExe config.programs.dank-material-shell.package;

  # Turns night mode on from 20:00 (8pm) until 06:00 (6am), off otherwise.
  # State is recomputed from the current time on every run, so it is correct
  # whenever the unit fires: a schedule boundary, login, or resume from suspend.
  nightModeScript = pkgs.writeShellScript "dms-night-mode" ''
    # Wait for the DMS IPC socket to come up (e.g. right after login).
    for _ in $(${pkgs.coreutils}/bin/seq 1 30); do
      ${dmsBin} ipc call night status >/dev/null 2>&1 && break
      ${pkgs.coreutils}/bin/sleep 1
    done

    hour=$((10#$(${pkgs.coreutils}/bin/date +%H)))

    if [ "$hour" -ge 20 ] || [ "$hour" -lt 6 ]; then
      ${dmsBin} ipc call night enable
    else
      ${dmsBin} ipc call night disable
    fi
  '';
in {
  options.desktops.addons.dms = with types; {
    enable = mkBoolOpt false "Whether to enable DankMaterialShell";
    isLaptop = mkBoolOpt false "Whether this is a laptop (controls battery visibility)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
    ];

    programs.dank-material-shell = {
      enable = true;
      systemd.enable = true;
      enableSystemMonitoring = true;
      enableVPN = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = false;
      enableClipboardPaste = true;

      settings = {
        useFahrenheit = true;
        fontWeight = 600;
        fontScale = 1.3;

        barConfigs = [
          {
            id = "default";
            name = "Main Bar";
            enabled = true;
            position = 0;
            screenPreferences = [
              "all"
            ];
            showOnLastDisplay = true;
            leftWidgets = [
              "launcherButton"
              "workspaceSwitcher"
              "focusedWindow"
              {
                id = "appsDock";
                enabled = true;
              }
            ];
            centerWidgets = [
              "music"
              "clock"
              "weather"
            ];
            rightWidgets = [
              {
                id = "systemTray";
                enabled = true;
              }
              {
                id = "clipboard";
                enabled = true;
              }
              {
                id = "cpuUsage";
                enabled = true;
              }
              {
                id = "memUsage";
                enabled = true;
              }
              {
                id = "gpuTemp";
                enabled = true;
                selectedGpuIndex = 0;
                pciId = "1002:7550";
              }
              {
                id = "notificationButton";
                enabled = true;
              }
              {
                id = "battery";
                enabled = true;
              }
              {
                id = "controlCenterButton";
                enabled = true;
              }
              {
                id = "privacyIndicator";
                enabled = true;
              }
              {
                id = "vpn";
                enabled = true;
              }
              {
                id = "capsLockIndicator";
                enabled = true;
              }
            ];
            spacing = 4;
            innerPadding = 16;
            bottomGap = 0;
            transparency = 0.9;
            widgetTransparency = 0.95;
            squareCorners = false;
            noBackground = false;
            gothCornersEnabled = false;
            gothCornerRadiusOverride = false;
            gothCornerRadiusValue = 12;
            borderEnabled = false;
            borderColor = "surfaceText";
            borderOpacity = 1;
            borderThickness = 1;
            fontScale = 1;
            autoHide = false;
            autoHideDelay = 250;
            openOnOverview = false;
            visible = true;
            popupGapsAuto = true;
            popupGapsManual = 4;
            widgetPadding = 8;
            iconScale = 1.2;
          }
        ];

        builtInPluginSettings = {
          dms_settings_search = {
            trigger = "?";
          };
        };
      };

      plugins = {
        calculator = {
          enable = true;
          src = pkgs.fetchFromGitHub {
            owner = "rochacbruno";
            repo = "DankCalculator";
            rev = "0.2.2";
            sha256 = "1sb26kc9k9jcgkssx4xf35im2h5h7hkb8g66wxlj5w7pnbcpc5bf";
          };
          settings = {
            trigger = "=";
          };
        };
      };
    };

    programs.dsearch.enable = true;

    # Automatically switch DankMaterialShell night mode on at 8pm / off at 6am.
    systemd.user.services.dms-night-mode = {
      Unit = {
        Description = "Apply DankMaterialShell night mode based on time of day";
        After = ["dms.service" "graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${nightModeScript}";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    systemd.user.timers.dms-night-mode = {
      Unit.Description = "Toggle DankMaterialShell night mode at 20:00 and 06:00";
      Timer = {
        OnCalendar = ["*-*-* 20:00:00" "*-*-* 06:00:00"];
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };

    desktops.addons.hypridle = {
      lock_cmd = mkForce "dms ipc call lock lock";
      before_sleep_cmd = mkForce "dms ipc call lock lock";
      after_sleep_cmd = mkForce "sleep 1 && hyprctl dispatch dpms on";
    };
  };
}
