{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.programs.devenv;
in {
  options.cli.programs.devenv = with types; {
    enable = mkBoolOpt false "Whether or not to enable devenv";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devenv
    ];

    # devenv integrates with direnv via `use devenv` in .envrc
    cli.programs.direnv.enable = true;
  };
}
