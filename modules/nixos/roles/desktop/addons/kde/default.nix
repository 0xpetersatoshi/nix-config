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
          package = pkgs.kdePackages.sddm;
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

      xserver = {
        enable = true;
        desktopManager.plasma5 = {
          enable = true;
          useQtScaling = true;
        };
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

    programs.dconf.enable = true;
  };
}
