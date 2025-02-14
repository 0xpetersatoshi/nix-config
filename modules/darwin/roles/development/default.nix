{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.roles.development;
in {
  options.roles.development = {
    enable = lib.mkEnableOption "Enable development guis";
  };

  config = lib.mkIf cfg.enable {
    programs.guis.development.enable = true;

    environment.systemPackages = with pkgs; [
      cctools
      darwin.libiconv
      # darwin.xcode_16_2
    ];

    environment.variables = {
      LIBRARY_PATH = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib";
    };
  };
}
