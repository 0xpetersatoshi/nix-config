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

  browser = ["brave-browser.desktop"];
  pdfApp = ["com.github.johnfactotum.Foliate.desktop"];
  fileManager = ["org.kde.dolphin.desktop"];
  editor = ["nvim.desktop"];
  archivesApp = ["org.kde.ark.desktop"];
  terminal = ["com.mitchellh.ghostty.desktop"];
  mail = ["thunderbird.desktop"];
  image = ["org.kde.gwenview.desktop"];
  video = ["vlc.desktop"];

  # XDG MIME types
  associations = {
    "application/json" = editor;
    "application/pdf" = pdfApp;
    "application/rss+xml" = editor;

    "application/x-arj" = archivesApp;
    "application/x-bzip" = archivesApp;
    "application/x-bzip-compressed-tar" = archivesApp;
    "application/x-compress" = archivesApp;
    "application/x-compressed-tar" = archivesApp;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-ics" = mail;
    "application/x-extension-m4a" = video;
    "application/x-extension-mp4" = video;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xht" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-flac" = video;
    "application/x-gzip" = archivesApp;
    "application/x-lha" = archivesApp;
    "application/x-lhz" = archivesApp;
    "application/x-lzop" = archivesApp;
    "application/x-matroska" = video;
    "application/x-netshow-channel" = video;
    "application/x-quicktime-media-link" = video;
    "application/x-quicktimeplayer" = video;
    "application/x-rar" = archivesApp;
    "application/x-shellscript" = editor;
    "application/x-smil" = video;
    "application/x-tar" = archivesApp;
    "application/x-tarz" = archivesApp;
    "application/x-zoo" = archivesApp;
    "application/xhtml+xml" = browser;
    "application/xml" = editor;
    "application/zip" = archivesApp;
    "audio/*" = video;
    "image/*" = image;
    "image/bmp" = image;
    "image/gif" = image;
    "image/jpeg" = image;
    "image/jpg" = image;
    "image/pjpeg" = image;
    "image/png" = image;
    "image/tiff" = image;
    "image/x-icb" = image;
    "image/x-ico" = image;
    "image/x-pcx" = image;
    "image/x-portable-anymap" = image;
    "image/x-portable-bitmap" = image;
    "image/x-portable-graymap" = image;
    "image/x-portable-pixmap" = image;
    "image/x-xbitmap" = image;
    "image/x-xpixmap" = image;
    "image/x-xwindowdump" = image;
    "inode/directory" = fileManager;
    "message/rfc822" = mail;
    "text/*" = editor;
    "text/calendar" = mail;
    "text/html" = browser;
    "text/plain" = editor;
    "video/*" = video;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/chrome" = browser;
    "x-scheme-handler/discord" = ["discord.desktop"];
    "x-scheme-handler/etcher" = ["balena-etcher-electron.desktop"];
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/mailto" = mail;
    "x-scheme-handler/mid" = mail;
    "x-scheme-handler/terminal" = terminal;
    "x-scheme-handler/tg" = ["org.telegram.desktop"];
    "x-scheme-handler/unknown" = browser;
    "x-scheme-handler/webcal" = mail;
    "x-scheme-handler/webcals" = mail;
    "x-www-browser" = browser;
  };
in {
  options.desktops.addons.xdg = with types; {
    enable = mkBoolOpt false "manage xdg config";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = mkIf pkgs.stdenv.isLinux {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      # Ensure XDG_DATA_DIRS includes both system and user application directories
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:${config.home.profileDirectory}/share:/run/current-system/sw/share";
      HISTFILE = lib.mkForce "${config.xdg.stateHome}/bash/history";
      GTK2_RC_FILES = lib.mkForce "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };

    home.sessionPath = ["$HOME/.local/bin"];
    home.file.".local/bin" = {
      source = ../../../../../scripts/bin;
      recursive = true;
    };

    home.packages = with pkgs; [
      xdg-utils
    ];

    xdg = {
      enable = true;
      cacheHome = config.home.homeDirectory + "/.local/cache";

      portal = mkIf pkgs.stdenv.isLinux {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          kdePackages.xdg-desktop-portal-kde
          xdg-desktop-portal-gtk
        ];
        config = {
          common = {
            default = "kde";

            "org.freedesktop.impl.portal.Access" = "kde";
            "org.freedesktop.impl.portal.Account" = "kde";
            "org.freedesktop.impl.portal.AppChooser" = "kde";
            "org.freedesktop.impl.portal.DynamicLauncher" = "kde";
            "org.freedesktop.impl.portal.Email" = "kde";
            "org.freedesktop.impl.portal.FileChooser" = "kde";
            "org.freedesktop.impl.portal.Lockdown" = "kde";
            "org.freedesktop.impl.portal.Notification" = "kde";
            "org.freedesktop.impl.portal.Print" = "kde";
            "org.freedesktop.impl.portal.Screencast" = "kde";
            "org.freedesktop.impl.portal.Screenshot" = "kde";
            # "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
            # "org.freedesktop.impl.portal.Background" = "gnome";
            # "org.freedesktop.impl.portal.Clipboard" = "gnome";
            # "org.freedesktop.impl.portal.InputCapture" = "gnome";
            # "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
          };
          hyprland = {
            default = ["hyprland" "kde" "gtk"];
            "org.freedesktop.impl.portal.Screencast" = "hyprland";
            "org.freedesktop.impl.portal.FileChooser" = "kde";
            "org.freedesktop.impl.portal.AppChooser" = "kde";
          };
          # Explicitly set the portal implementation for specific interfaces
          kde = {
            default = ["kde" "gtk"];
            "org.freedesktop.impl.portal.FileChooser" = "kde";
            "org.freedesktop.impl.portal.AppChooser" = "kde";
          };
        };
        # Set to false to use the native xdg-open implementation
        xdgOpenUsePortal = true;
      };

      mimeApps = mkIf pkgs.stdenv.isLinux {
        enable = true;
        associations.added = associations;
        defaultApplications = associations;
      };

      userDirs = mkIf pkgs.stdenv.isLinux {
        enable = true;
        createDirectories = true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
        };
      };
    };
  };
}
