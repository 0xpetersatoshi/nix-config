{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.styles.theming;
in {
  options.styles.theming = {
    enable = lib.mkEnableOption "Enable theming packages";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # --------------------------------------------------- // Theming
      nwg-look # gtk configuration tool
      kdePackages.breeze-icons # KDE's icon set, good for Qt apps
      kdePackages.qt6ct # qt6 configuration tool
      kdePackages.qtstyleplugin-kvantum # svg based qt6 theme engine
      gtk3 # gtk3
      gtk4 # gtk4
      glib # gtk theme management
      gsettings-desktop-schemas # gsettings schemas
      gnome-settings-daemon # for gnome settings
      desktop-file-utils # for updating desktop database
      hicolor-icon-theme # Base fallback icon theme
      adwaita-icon-theme # Standard GNOME icons, excellent fallback
      dconf-editor # dconf editor
      gnome-tweaks # gnome tweaks
    ];
  };
}
