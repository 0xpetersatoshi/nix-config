{
  config,
  lib,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.system.zram;
in {
  options.system.zram = {
    enable = mkBoolOpt false "Whether or not to enable zram.";
  };

  config = mkIf cfg.enable {
    zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 100;
    priority = 999;
  };
  };
}
