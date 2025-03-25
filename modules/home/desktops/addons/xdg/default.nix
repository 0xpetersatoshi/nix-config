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
      portal = mkIf pkgs.stdenv.isLinux {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gtk
          kdePackages.xdg-desktop-portal-kde
        ];
        config = {
          common.default = "kde";
          hyprland.default = ["kde" "gtk"];
          # Explicitly set the portal implementation for specific interfaces
          kde = {
            default = ["kde" "gtk"];
            "org.freedesktop.impl.portal.FileChooser" = "kde";
            "org.freedesktop.impl.portal.AppChooser" = "kde";
          };
        };
        # Set to false to use the native xdg-open implementation
        xdgOpenUsePortal = false;
      };

      mimeApps = mkIf pkgs.stdenv.isLinux {
        enable = true;
        associations.added = {
          # Add these associations to ensure they're registered
          "image/jpeg" = ["org.kde.gwenview.desktop"];
          "image/png" = ["org.kde.gwenview.desktop"];
          "image/gif" = ["org.kde.gwenview.desktop"];
          "image/svg+xml" = ["org.kde.gwenview.desktop"];
          "application/pdf" = ["com.github.johnfactotum.Foliate.desktop"];
        };
        defaultApplications = {
          # Web
          "text/html" = ["microsoft-edge.desktop"];
          "x-scheme-handler/http" = ["microsoft-edge.desktop"];
          "x-scheme-handler/https" = ["microsoft-edge.desktop"];
          "x-scheme-handler/chrome" = ["microsoft-edge.desktop"];
          "application/x-extension-htm" = ["microsoft-edge.desktop"];
          "application/x-extension-html" = ["microsoft-edge.desktop"];
          "application/x-extension-shtml" = ["microsoft-edge.desktop"];
          "application/xhtml+xml" = ["microsoft-edge.desktop"];
          "application/x-extension-xhtml" = ["microsoft-edge.desktop"];
          "application/x-extension-xht" = ["microsoft-edge.desktop"];

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
