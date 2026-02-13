{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.web3;
in {
  options.cli.programs.web3 = with types; {
    enable = mkBoolOpt false "Whether or not to enable web3 dev packages";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      foundry
      slither-analyzer
    ];
  };
}
