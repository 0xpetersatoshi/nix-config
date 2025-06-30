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

    # Enable NFS client support
    boot.supportedFilesystems = ["nfs"];
    services.rpcbind.enable = true;
  };
}
