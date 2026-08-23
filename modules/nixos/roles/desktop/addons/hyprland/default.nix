{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.desktop.addons.hyprland;
in {
  options.roles.desktop.addons.hyprland = with types; {
    enable = mkBoolOpt false "Enable or disable the hyprland window manager.";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    # uwsm is what actually manages the session (it owns graphical-session.target),
    # so point the greeter at the uwsm entry.
    services.displayManager.defaultSession = "hyprland-uwsm";

    # pkgs.hyprland ships BOTH hyprland.desktop and hyprland-uwsm.desktop
    # (providedSessions = ["hyprland" "hyprland-uwsm"]) and the module gives no way
    # to pick one. The plain entry is a trap now: nothing starts
    # graphical-session.target under it, so the bar/shell never comes up.
    #
    # sessionPackages is a list, so overriding it would drop every other
    # contributor (steam's gamescope session, whose package is private to that
    # module). Point the greeter at a filtered copy instead -- steam and any
    # future session package come through untouched. hyprland.desktop itself must
    # stay installed: uwsm's Exec line resolves it by name out of XDG_DATA_DIRS.
    services.displayManager.sddm.settings.Wayland.SessionDir = mkIf config.services.displayManager.sddm.enable "${pkgs.runCommand "wayland-sessions-uwsm-only" {
      preferLocalBuild = true;
      allowSubstitutes = false;
    } ''
      cp -rL ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions $out
      chmod -R u+w $out
      rm -f $out/hyprland.desktop
    ''}";

    security.pam.services = {
      hyprlock = {
        # Disable u2f authentication for hyprlock
        u2fAuth = lib.mkForce false;
        # Standard PAM configuration for screen lockers
        text = ''
          # Account management
          account required pam_unix.so

          # Authentication management
          auth sufficient pam_unix.so try_first_pass likeauth nullok
          auth required pam_deny.so

          # Password management
          password sufficient pam_unix.so nullok sha512

          # Session management
          session required pam_env.so
          session required pam_unix.so
        '';
      };
      swaylock = {
        u2fAuth = lib.mkForce false;
      };
    };

    # NOTE: handles input devices (i.e. touchpads) in Wayland compositors
    services.libinput.enable = true;
    services.xserver.windowManager.fvwm2.gestures = true;

    environment.systemPackages = with pkgs; [
      libinput
      libinput-gestures
      wmctrl
      xdotool
    ];
  };
}
