{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.kubernetes;
in {
  options.cli.programs.kubernetes = with types; {
    enable = mkBoolOpt false "Whether or not to enable kubernetes cli tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kubectl
      kubectx
    ];
  };
}
