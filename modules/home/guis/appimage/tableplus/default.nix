{
  pkgs,
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.guis.appimage.tableplus;

  # TablePlus version and download details
  tablePlusVersion = "x64";
  tablePlusAppImageName = "TablePlus-${tablePlusVersion}.AppImage";
  tablePlusUrl = "https://tableplus.com/release/linux/x64/${tablePlusAppImageName}";

  # Create a derivation to download the TablePlus AppImage
  tablePlusAppImage = pkgs.fetchurl {
    url = tablePlusUrl;
    sha256 = "sha256-OpHFNZg0CbDW88XHGl+sAL3b767ga03Iw2tx5vjPeco=";
    executable = true;
  };

  # Icon for TablePlus
  tablePlusIcon = pkgs.fetchurl {
    url = "https://user-images.githubusercontent.com/806104/89695066-59d6b400-d8d8-11ea-99a0-365d3dc36630.png";
    sha256 = "sha256-++G0u0qer2sYkz99BhhFDQY0qzKBEGmUqMt9uHQIYRQ=";
  };

  # Create a wrapper script to run TablePlus with appimage-run
  tablePlusWrapper = pkgs.writeShellScriptBin "tableplus" ''
    exec ${pkgs.appimage-run}/bin/appimage-run "${tablePlusAppImage}" "$@"
  '';
in {
  options.guis.appimage.tableplus = with types; {
    enable = mkBoolOpt false "Whether or not to manage podman";
  };

  config = mkIf cfg.enable {
    home.packages = [
      tablePlusWrapper
    ];

    # Create the desktop entry
    xdg.desktopEntries.tableplus = {
      name = "TablePlus";
      comment = "Modern, native, and friendly GUI tool for relational databases";
      exec = "tableplus %F";
      icon = "${tablePlusIcon}";
      terminal = false;
      type = "Application";
      categories = ["Development" "Database"];
      # startupWMClass = "TablePlus";
    };
  };
}
