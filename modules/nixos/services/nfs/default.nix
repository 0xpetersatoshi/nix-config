{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.${namespace}.nfs;
in {
  options.services.${namespace}.nfs = with types; {
    enable = mkEnableOption "Enable nfs";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        nfs-utils
      ];
    };

    # optional, but ensures rpc-statsd is running for on demand mounting
    boot.supportedFilesystems = ["nfs"];
  };
}
