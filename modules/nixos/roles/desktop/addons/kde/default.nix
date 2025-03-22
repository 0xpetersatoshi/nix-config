{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.desktop.addons.kde;
in {
  options.roles.desktop.addons.kde = with types; {
    enable = mkBoolOpt false "Enable or disable KDE components";
  };

  config = mkIf cfg.enable {
    environment.pathsToLink = [
      "/share/themes"
    ];

    services = {
      displayManager = {
        sddm = {
          enable = true;
          wayland = {
            enable = true;
            compositor = "kwin";
          };

          extraPackages = with pkgs; [
            kdePackages.qtsvg
            kdePackages.qtmultimedia
            kdePackages.qtvirtualkeyboard
          ];

          theme = "sddm-astronaut-theme";
          settings = {
            General = {
              GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
            };
            Theme = {
              ThemeDir = "/run/current-system/sw/share/sddm/themes";
              # CursorTheme = "Bibata-Modern-Ice";
            };
          };
        };
        sessionPackages = [pkgs.hyprland];
      };

      desktopManager.plasma6 = {
        enable = true;
        enableQt5Integration = false;
      };
    };

    environment.systemPackages = with pkgs; [
      (unstable.sddm-astronaut.override {
        embeddedTheme = "pixel_sakura";
        # themeConfig = {
        #   FontSize = 20;
        # };
      })

      polkit_gnome # polkit gui
    ];

    programs = {
      dconf.enable = true;
      kdeconnect = {
        enable = true;
        package = lib.mkForce pkgs.kdePackages.kdeconnect-kde;
      };
    };
  };
}
