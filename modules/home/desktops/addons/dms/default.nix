{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.desktops.addons.dms;
in {
  options.desktops.addons.dms = with types; {
    enable = mkBoolOpt false "Whether to enable DankMaterialShell";
    isLaptop = mkBoolOpt false "Whether this is a laptop (controls battery visibility)";
  };

  config = mkIf cfg.enable {
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
    };

    desktops.addons.hypridle = {
      lock_cmd = mkForce "dms ipc call lock lock";
      before_sleep_cmd = mkForce "dms ipc call lock lock";
      after_sleep_cmd = mkForce "sleep 1 && hyprctl dispatch dpms on";
    };
  };
}
