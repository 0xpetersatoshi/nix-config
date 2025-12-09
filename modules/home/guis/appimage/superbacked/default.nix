{
  pkgs,
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.guis.appimage.superbacked;

  # superbacked version and download details
  arch = "x64";
  version = "1.8.0";
  superbackedAppImageName = "superbacked-${arch}-${version}.AppImage";
  superbackedUrl = "https://github.com/superbacked/superbacked/releases/download/v${version}/${superbackedAppImageName}";

  # Create a derivation to download the superbacked AppImage
  superbackedAppImage = pkgs.fetchurl {
    url = superbackedUrl;
    sha256 = "sha256-vOESLmmyVnUIgWZ1I8omujhlo2VV2Fx0119yfH2cF8w=";
    executable = true;
  };

  # Icon for superbacked
  superbackedIcon = pkgs.fetchurl {
    url = "https://avatars.githubusercontent.com/u/110472974";
    sha256 = "sha256-NILmrMaDJHhzNVOLqAWabC78FGPCcssfS3J3zjEhel8=";
  };

  # Create a wrapper script to run superbacked with appimage-run
  superbackedWrapper = pkgs.writeShellScriptBin "superbacked" ''
    exec ${pkgs.appimage-run}/bin/appimage-run "${superbackedAppImage}" "$@"
  '';
in {
  options.guis.appimage.superbacked = with types; {
    enable = mkBoolOpt false "Enable superbacked";
  };

  config = mkIf cfg.enable {
    home.packages = [
      superbackedWrapper
    ];

    # Create the desktop entry
    xdg.desktopEntries.superbacked = {
      name = "superbacked";
      comment = "Secret management platform used to back up and pass on sensitive data from one generation to the next.";
      exec = "superbacked %F";
      icon = "${superbackedIcon}";
      terminal = false;
      type = "Application";
      categories = ["Development" "Database"];
      # startupWMClass = "superbacked";
    };
  };
}
