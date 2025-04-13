{
  pkgs,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.hardware;
in {
  options.cli.programs.hardware = with types; {
    enable = mkBoolOpt false "Whether or not to enable hardware tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      parted
      qemu
    ];
  };
}
