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

      age.keyFile = "/home/${config.user.name}/.config/sops/age/keys.txt";
    };
  };
}
