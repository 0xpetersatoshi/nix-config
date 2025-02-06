{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.desktop.addons.plasma;
in {
  options.roles.desktop.addons.plasma = with types; {
    enable = mkBoolOpt false "Enable or disable the plasma DE.";
  };

  config = mkIf cfg.enable {
    services = {
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };

        defaultSession = "hyprland-uwsm";
      };

      xserver = {
        enable = true;
        desktopManager.plasma5 = {
          enable = true;
        };
      };
    };

    qt = {
      enable = true;
      platformTheme = "qt5ct";
      style = "kvantum";
    };

    programs.dconf.enable = true;
  };
}
