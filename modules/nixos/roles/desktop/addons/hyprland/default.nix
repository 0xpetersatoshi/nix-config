{
  config,
  lib,
  namespace,
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
      hyprlock = {};
      swaylock = {};
    };

    # NOTE: handles input devices (i.e. touchpads) in Wayland compositors
    services.libinput.enable = true;

    environment.etc."xdg/xdg-desktop-portal/portals.conf".text = ''
      [preferred]
      default=hyprland
    '';
  };
}
