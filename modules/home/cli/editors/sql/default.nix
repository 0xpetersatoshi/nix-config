{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.editors.sql;
in {
  options.cli.editors.sql = with types; {
    enable = mkBoolOpt false "enable sql editors";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      harlequin
      unstable.lazysql
      unstable.atlas
    ];
  };
}
