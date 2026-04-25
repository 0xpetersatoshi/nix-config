{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cloud.aws;
in {
  options.cloud.aws = with types; {
    enable = mkBoolOpt false "Whether or not to enable aws cloud sdk";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      awscli2
    ];
  };
}
