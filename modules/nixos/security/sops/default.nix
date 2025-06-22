{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.security.${namespace}.sops;
in {
  options.security.${namespace}.sops = with types; {
    enable = mkBoolOpt false "Whether to enable sop for secrets management.";
  };

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = lib.snowfall.fs.get-file "modules/nixos/secrets.yaml";
      defaultSopsFormat = "yaml";

      gnupg.home = "/home/${config.user.name}/.gnupg";
      # Ensure sops can access secrets during boot
      gnupg.sshKeyPaths = [];
    };
  };
}
