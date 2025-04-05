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

          extraPackages = with pkgs; [
            kdePackages.qtmultimedia
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
    ];

    security.pam.services = {
      sddm = {
        kwallet = {
          enable = true;
          package = pkgs.kdePackages.kwallet-pam;
        };
        text = ''
          auth     optional     ${pkgs.kdePackages.kwallet-pam}/lib/security/pam_kwallet5.so
          session  optional     ${pkgs.kdePackages.kwallet-pam}/lib/security/pam_kwallet5.so auto_start
        '';
      };
    };

    programs = {
      kdeconnect = {
        enable = true;
      };
    };
  };
}
