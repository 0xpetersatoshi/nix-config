{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.desktops.addons.hyprlock;

  # Define script names as variables
  unlockScriptName = "hyprland-unlock";
  lockScriptName = "hyprland-lock";

  # Create the scripts with their content
  unlockScript = pkgs.writeShellScriptBin unlockScriptName ''
    #!/usr/bin/env bash
    # Wait for the system to fully resume
    sleep 1
    # Ensure display is on
    hyprctl dispatch dpms on
    # Force focus on hyprlock
    hyprctl dispatch focuswindow hyprlock
    # Simulate a click in the center of the screen where the input box should be
    SCREEN_WIDTH=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[0].width')
    SCREEN_HEIGHT=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[0].height')
    CENTER_X=$((SCREEN_WIDTH / 2))
    CENTER_Y=$((SCREEN_HEIGHT / 2 + 100))
    # Move to center and click
    ${pkgs.xdotool}/bin/xdotool mousemove $CENTER_X $CENTER_Y
    ${pkgs.xdotool}/bin/xdotool click 1
    # Return focus to hyprlock
    hyprctl dispatch focuswindow hyprlock
  '';

  lockScript = pkgs.writeShellScriptBin lockScriptName ''
    #!/usr/bin/env bash
    # Kill any existing hyprlock instances
    killall hyprlock 2>/dev/null
    # Wait a moment
    sleep 0.1
    # Lock the session
    loginctl lock-session
    # Ensure hyprlock is running
    if ! pgrep hyprlock >/dev/null; then
      hyprctl dispatch exec "hyprlock"
    fi
    # Wait for hyprlock to start
    sleep 0.3
    # Force focus on hyprlock
    hyprctl dispatch focuswindow hyprlock
    # Simulate a click in the center of the screen where the input box should be
    SCREEN_WIDTH=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[0].width')
    SCREEN_HEIGHT=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[0].height')
    CENTER_X=$((SCREEN_WIDTH / 2))
    CENTER_Y=$((SCREEN_HEIGHT / 2 + 100))
    # Move to center and click
    ${pkgs.xdotool}/bin/xdotool mousemove $CENTER_X $CENTER_Y
    ${pkgs.xdotool}/bin/xdotool click 1
    # Return focus to hyprlock
    hyprctl dispatch focuswindow hyprlock
  '';

  # Path to the unlock script in the user's profile
  unlockScriptPath = "${config.home.homeDirectory}/.nix-profile/bin/${unlockScriptName}";
in {
  options.desktops.addons.hyprlock = with types; {
    enable = mkBoolOpt false "Whether to enable hyprlock";
  };

  config = mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 0;
          hide_cursor = false;
          no_fade_in = true;
          immediate_input_grab = true;
          immediate_focus = true;
          hide_input_when_idle = false;
        };

        label = {
          text = "$TIME";
          font_size = 96;
          font_family = "JetBrains Mono";
          color = "rgba(235, 219, 178, 1.0)";
          position = "0, 600";
          halign = "center";
          walign = "center";
          shadow_passes = 1;
        };

        input-field = {
          size = "250, 60";
          outline_thickness = 4;
          dots_size = 0.33;
          dots_spacing = 0.15;
          fade_on_empty = false;
          placeholder_text = "<b>Password...</b>";
          halign = "center";
          valign = "center";
          always_active = true;
        };
      };
    };

    # Add the helper scripts and dependencies
    home.packages = with pkgs; [
      xdotool
      jq
      unlockScript
      lockScript
    ];

    # Create systemd user service
    systemd.user.services = {
      hyprland-resume-fix = {
        Unit = {
          Description = "Fix Hyprland/Hyprlock after resume";
          After = "suspend.target";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScript "hyprland-unlock-cmd" ''
            # Wait for the system to fully resume
            sleep 2
            # Run the resume fix script
            ${unlockScriptPath}
          ''}";
          Environment = "DISPLAY=:0 WAYLAND_DISPLAY=wayland-0";
        };
        Install = {
          WantedBy = ["suspend.target"];
        };
      };
    };
  };
}
