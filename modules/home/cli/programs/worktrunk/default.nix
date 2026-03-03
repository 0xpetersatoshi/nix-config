{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.worktrunk;
in {
  options.cli.programs.worktrunk = with types; {
    enable = mkBoolOpt false "Whether or not to enable the worktrunk (wt) CLI";
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.worktrunk.packages."${pkgs.system}".default
    ];
  };
}
