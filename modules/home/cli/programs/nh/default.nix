{
  pkgs,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.nh;
in {
  options.cli.programs.nh = with types; {
    enable = mkBoolOpt false "Whether or not to enable the nh cli helper";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nh
      nix-output-monitor
      nvd
    ];
  };
}
