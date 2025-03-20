{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.programs.build;
in {
  options.cli.programs.build = with types; {
    enable = mkBoolOpt false "Whether or not to enable build tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnumake
    ];
  };
}
