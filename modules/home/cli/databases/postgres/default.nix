{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.databases.postgres;
in {
  options.cli.databases.postgres = with types; {
    enable = mkBoolOpt false "Whether or not to enable postgres";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      postgresql
    ];
  };
}
