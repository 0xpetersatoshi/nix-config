{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.pi;
in {
  options.cli.programs.pi = with types; {
    enable = mkBoolOpt false "Whether or not to enable the pi tui";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.pi-coding-agent];
  };
}
