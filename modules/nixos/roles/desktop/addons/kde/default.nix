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
  sddm-candy = pkgs.callPackage ../../../../../../themes/sddm/candy.nix {};
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
          package = pkgs.libsForQt5.sddm;
          extraPackages = with pkgs; [
            libsForQt5.qt5.qtquickcontrols # for sddm theme ui elements
            libsForQt5.layer-shell-qt # for sddm theme wayland support
            libsForQt5.qt5.qtquickcontrols2 # for sddm theme ui elements
            libsForQt5.qt5.qtgraphicaleffects # for sddm theme effects
            libsForQt5.qtsvg # for sddm theme svg icons
            libsForQt5.qt5.qtwayland # wayland support for qt5
          ];
          theme = "Candy";
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
        };
      };
    };

    environment.systemPackages = with pkgs; [
      sddm-candy
      libsForQt5.qt5.qtquickcontrols # for sddm theme ui elements
      libsForQt5.layer-shell-qt # for sddm theme wayland support
      libsForQt5.qt5.qtquickcontrols2 # for sddm theme ui elements
      libsForQt5.qt5.qtgraphicaleffects # for sddm theme effects
      libsForQt5.qtsvg # for sddm theme svg icons
      libsForQt5.qt5.qtwayland # wayland support for qt5

      polkit_gnome # polkit gui
    ];

    # qt = {
    #   enable = true;
    #   platformTheme = "qt5ct";
    #   style = "kvantum";
    # };

    programs.dconf.enable = true;
  };
}
