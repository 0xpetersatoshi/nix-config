{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.ai.omp;
in {
  options.cli.ai.omp = with types; {
    enable = mkBoolOpt false "Whether or not to enable omp (oh-my-pi) coding agent";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.omp];
  };
}
