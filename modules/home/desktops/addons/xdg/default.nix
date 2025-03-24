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
    home.sessionVariables = mkIf pkgs.stdenv.isLinux {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
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
      portal = mkIf pkgs.stdenv.isLinux {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gtk
          kdePackages.xdg-desktop-portal-kde
        ];
        config.common.default = "hyprland";
        xdgOpenUsePortal = true;
      };

      mimeApps = mkIf pkgs.stdenv.isLinux {
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
          "text/html" = ["brave-browser.desktop"];
          "x-scheme-handler/http" = ["brave-browser.desktop"];
          "x-scheme-handler/https" = ["brave-browser.desktop"];
          "x-scheme-handler/chrome" = ["brave-browser.desktop"];
          "application/x-extension-htm" = ["brave-browser.desktop"];
          "application/x-extension-html" = ["brave-browser.desktop"];
          "application/x-extension-shtml" = ["brave-browser.desktop"];
          "application/xhtml+xml" = ["brave-browser.desktop"];
          "application/x-extension-xhtml" = ["brave-browser.desktop"];
          "application/x-extension-xht" = ["brave-browser.desktop"];

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
