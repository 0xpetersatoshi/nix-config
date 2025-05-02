{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.desktops.addons.kde;
in {
  options.desktops.addons.kde = {
    enable = mkEnableOption "enable kde addons";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Qt6/KDE Components
      ark # KDE file archiver
      kdePackages.dolphin # KDE file manager
      kdePackages.qtimageformats # Additional image format plugins for Qt6
      kdePackages.ffmpegthumbs # FFmpeg-based video thumbnails for Qt6
      kdePackages.kde-cli-tools # KDE command line tools
      kdePackages.kdegraphics-thumbnailers # KDE graphics file thumbnails
      kdePackages.kimageformats # Additional image format plugins for KDE
      kdePackages.plasma-nm # Applet for managing network connections
      kdePackages.qtimageformats # imageformats for Qt6
      kdePackages.qtwayland # Qt6 Wayland integration
      kdePackages.qtsvg # SVG support for Qt6
      kdePackages.qtbase # Qt6 base libraries
      kdePackages.kio # KDE Input/Output framework
      kdePackages.kio-extras # Additional KIO protocols and file systems
      kdePackages.kwayland # KDE Wayland integration library
      kdePackages.qt5compat # Qt5 compatibility layer for Qt6
      kdePackages.qtstyleplugin-kvantum # Qt6 Kvantum style plugin
      kdePackages.qt6ct # Qt6 configuration tool
      kdePackages.qt6gtk2 # GTK2-style widgets for Qt6
    ];
  };
}
