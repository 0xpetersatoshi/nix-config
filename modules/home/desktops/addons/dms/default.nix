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
      # required by the claudeCodeUsage plugin's get-claude-usage script
      jq
      curl
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

        # Arm the fingerprint reader on the DMS lock screen (shown on resume
        # from suspend). DMS only starts an fprintd PAM conversation when this
        # is on; it also self-gates on reader readiness, so it is a no-op on
        # machines without an enrolled reader. Uses DMS's bundled `fprint` PAM
        # stack (pam_fprintd), independent of the system PAM services.
        enableFprint = true;

        # Lock via DMS's native pre-suspend path instead of a fire-and-forget
        # IPC call from hypridle. DMS holds a logind delay inhibitor and only
        # releases it once the WlSessionLock (ext-session-lock) surface is
        # actually active, so the system never suspends with the desktop as the
        # last committed frame. Without this, the desktop is briefly visible on
        # resume before the lock finishes drawing. Requires loginctlLockIntegration
        # (default true). The hypridle before_sleep_cmd lock is dropped below so
        # DMS is the single, race-free owner of pre-suspend locking.
        lockBeforeSuspend = true;

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
                id = "claudeCodeUsage";
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

        # Control Center widgets. DMS replaces its built-in defaults with this
        # list wholesale, so the stock eight are reproduced here verbatim and
        # `builtin_tailscale` is the only addition -- DMS's native Tailscale
        # widget (connect toggle, online peer count, searchable peer list).
        #
        # It only lights up when TailscaleService.available is true, which
        # needs this user to own tailscaled's LocalAPI: see --operator in
        # modules/nixos/services/vpn/tailscale.
        controlCenterWidgets = [
          {
            id = "volumeSlider";
            enabled = true;
            width = 50;
          }
          {
            id = "brightnessSlider";
            enabled = true;
            width = 50;
          }
          {
            id = "wifi";
            enabled = true;
            width = 50;
          }
          {
            id = "bluetooth";
            enabled = true;
            width = 50;
          }
          {
            id = "audioOutput";
            enabled = true;
            width = 50;
          }
          {
            id = "audioInput";
            enabled = true;
            width = 50;
          }
          {
            id = "nightMode";
            enabled = true;
            width = 50;
          }
          {
            id = "darkMode";
            enabled = true;
            width = 50;
          }
          {
            id = "builtin_tailscale";
            enabled = true;
            width = 50;
          }
        ];

        builtInPluginSettings = {
          dms_settings_search = {
            trigger = "?";
          };
        };
      };

      plugins = {
        # Claude Code subscription usage in the bar: 5-hour rate-limit ring,
        # pacing, today/week/month tokens, estimated cost, and a weekly chart.
        # Reads ~/.claude/.credentials.json and ~/.claude/projects/ via its own
        # bash script, so it needs jq and curl on PATH (added to home.packages
        # below). Placed in the bar via the claudeCodeUsage widget entry above.
        claudeCodeUsage = {
          enable = true;
          src = pkgs.fetchFromGitHub {
            owner = "titeya";
            repo = "dms-claudecode";
            rev = "4c29b39f8299abbc113bfc085e28f805fde35e10";
            hash = "sha256-i5FdG7Q7dJfmxxf5b7tB/Gt/Y2h/muYMQg3S+pr7SgQ=";
          };
          settings = {
            refreshInterval = 5; # minutes (2-15)
            showPacing = true;
          };
        };

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
      # Pre-suspend locking is owned by DMS's native `lockBeforeSuspend` (above),
      # which gates the actual suspend on the session lock being active. Firing a
      # lock from hypridle here as well is racy — the IPC call returns before the
      # lock surface is up — and would let the desktop flash on resume.
      before_sleep_cmd = mkForce "";
      after_sleep_cmd = mkForce "sleep 1 && hyprctl dispatch dpms on";
    };
  };
}
