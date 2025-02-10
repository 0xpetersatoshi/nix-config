{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.desktops.addons.xdg;
in {
  options.desktops.addons.xdg = with types; {
    enable = mkBoolOpt false "manage xdg config";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      HISTFILE = lib.mkForce "${config.xdg.stateHome}/bash/history";
      GTK2_RC_FILES = lib.mkForce "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };

    home.packages = with pkgs; [
      xdg-utils
    ];

    xdg = {
      enable = true;
      # TODO: currently only available on unstable channel
      # autostart.enable = true;
      cacheHome = config.home.homeDirectory + "/.local/cache";
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-hyprland
          libsForQt5.xdg-desktop-portal-kde
        ];
        config.common.default = "*";
        xdgOpenUsePortal = true;
      };

      mimeApps = {
        enable = true;
        associations.added = {
          # "video/mp4" = ["org.gnome.Totem.desktop"];
          # "video/quicktime" = ["org.gnome.Totem.desktop"];
          # "video/webm" = ["org.gnome.Totem.desktop"];
          # "video/x-matroska" = ["org.gnome.Totem.desktop"];
          # "image/gif" = ["org.gnome.Loupe.desktop"];
          # "image/png" = ["org.gnome.Loupe.desktop"];
          # "image/jpg" = ["org.gnome.Loupe.desktop"];
          # "image/jpeg" = ["org.gnome.Loupe.desktop"];
        };
        defaultApplications = {
          # Web
          "text/html" = ["zen.desktop"];
          "x-scheme-handler/http" = ["zen.desktop"];
          "x-scheme-handler/https" = ["zen.desktop"];
          "x-scheme-handler/chrome" = ["zen.desktop"];
          "application/x-extension-htm" = ["zen.desktop"];
          "application/x-extension-html" = ["zen.desktop"];
          "application/x-extension-shtml" = ["zen.desktop"];
          "application/xhtml+xml" = ["zen.desktop"];
          "application/x-extension-xhtml" = ["zen.desktop"];
          "application/x-extension-xht" = ["zen.desktop"];

          # File manager
          "inode/directory" = ["org.kde.dolphin.desktop"];
          "x-scheme-handler/file" = ["org.kde.dolphin.desktop"];
          "x-scheme-handler/about" = ["org.kde.dolphin.desktop"];

          # Text
          "text/plain" = ["nvim.desktop"];

          # Images
          "image/jpeg" = ["org.kde.gwenview.desktop"];
          "image/png" = ["org.kde.gwenview.desktop"];
          "image/gif" = ["org.kde.gwenview.desktop"];
          "image/svg+xml" = ["org.kde.gwenview.desktop"];

          # Archives
          "application/zip" = ["org.kde.ark.desktop"];
          "application/x-tar" = ["org.kde.ark.desktop"];
          "application/x-compressed-tar" = ["org.kde.ark.desktop"];
          "application/x-7z-compressed" = ["org.kde.ark.desktop"];
          "application/x-rar" = ["org.kde.ark.desktop"];

          # PDF
          "application/pdf" = ["com.github.johnfactotum.Foliate.desktop"];

          # Terminal
          "application/x-terminal-emulator" = ["com.mitchellh.ghostty.desktop"];
        };
      };

      userDirs = {
        enable = true;
        createDirectories = true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
        };
      };
    };
  };
}
