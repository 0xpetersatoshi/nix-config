{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.foundry;
in {
  options.cli.programs.foundry = with types; {
    enable = mkBoolOpt false "Whether or not to enable foundry";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      foundry
    ];
  };
}
