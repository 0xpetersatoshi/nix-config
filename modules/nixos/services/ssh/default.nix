{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.${namespace}.ssh;
in {
  options.services.${namespace}.ssh = with types; {
    enable = mkBoolOpt false "Enable ssh";
    authorizedKeys = mkOpt (listOf str) [] "The public keys to apply.";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [22];

      settings = {
        PasswordAuthentication = false;
        StreamLocalBindUnlink = "yes";
        GatewayPorts = "clientspecified";
      };
    };
    users.users = {
      ${config.user.name}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMM7C5+/++7Q1d4L+z8KYTHMa41dA2bVr/D4hgtzvt2f vms"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDaigBicRWbbmjqKmNeW6RBw2zhJLxRfHL4CaTt5zzXn homelab"
      ];
    };
  };
}
