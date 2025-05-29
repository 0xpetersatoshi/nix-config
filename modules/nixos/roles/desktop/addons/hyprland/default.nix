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
