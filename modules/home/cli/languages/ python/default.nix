{
  pkgs,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.languages.python;
in {
  options.cli.languages.python = with types; {
    enable = mkBoolOpt false "Whether or not to enable python";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      poetry
      pyenv
      pyright
      python313
      ruff
      uv

      unstable.python313Packages.debugpy
      unstable.python313Packages.pip
    ];
  };
}
