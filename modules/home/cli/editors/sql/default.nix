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
      # unstable's harlequin pulls a broken python3.14 sqlfmt; use 26.05's
      stable.harlequin
      lazysql
      atlas
    ];
  };
}
