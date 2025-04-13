{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.networking;
in {
  options.hardware.networking = with types; {
    enable = mkBoolOpt false "Enable networkmanager";
  };

  config = mkIf cfg.enable {
    networking = {
      firewall = {
        enable = true;
        # allow SMB traffic
        allowedTCPPorts = [139 445];
        # allow NetBIOS name resolution
        allowedUDPPorts = [137 138];
      };
      networkmanager.enable = true;
    };
    # environment.persistence."/persist".directories = [
    #   "/etc/NetworkManager"
    # ];
  };
}
