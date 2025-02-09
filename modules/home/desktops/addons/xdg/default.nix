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
          xdg-desktop-portal-hyprland
        ];
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
          "application/x-extension-htm" = "zen";
          "application/x-extension-html" = "zen";
          "application/x-extension-shtml" = "zen";
          "application/x-extension-xht" = "zen";
          "application/x-extension-xhtml" = "zen";
          "application/xhtml+xml" = "zen";
          "text/html" = "zen";
          "x-scheme-handler/about" = "zen";
          "x-scheme-handler/chrome" = ["chromium-browser.desktop"];
          "x-scheme-handler/ftp" = "zen";
          "x-scheme-handler/http" = "zen";
          "x-scheme-handler/https" = "zen";
          "x-scheme-handler/unknown" = "zen";

          # TODO: configure for kde
          # "audio/*" = ["mpv.desktop"];
          # "video/*" = ["org.gnome.Totem.desktop"];
          # "video/mp4" = ["org.gnome.Totem.desktop"];
          # "video/x-matroska" = ["org.gnome.Totem.desktop"];
          # "image/*" = ["org.gnome.loupe.desktop"];
          # "image/png" = ["org.gnome.loupe.desktop"];
          # "image/jpg" = ["org.gnome.loupe.desktop"];
          # "application/json" = ["gnome-text-editor.desktop"];
          # "application/pdf" = "zen";
          # "application/x-gnome-saved-search" = ["org.gnome.Nautilus.desktop"];
          # "x-scheme-handler/discord" = ["discord.desktop"];
          # "x-scheme-handler/spotify" = ["spotify.desktop"];
          # "x-scheme-handler/tg" = ["telegramdesktop.desktop"];
          # "application/toml" = "org.gnome.TextEditor.desktop";
          # "text/plain" = "org.gnome.TextEditor.desktop";
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
