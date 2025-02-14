{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.programs.nh;
in {
  options.cli.programs.nh = with types; {
    enable = mkBoolOpt false "Whether or not to enable modern unix tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nh
      nix-output-monitor
      nvd
    ];
  };
}
