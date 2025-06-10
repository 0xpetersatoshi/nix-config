{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.security.sops;
in {
  options.${namespace}.security.sops = with types; {
    enable = mkBoolOpt false "Whether to enable sops for secrets management.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sops
    ];

    sops = {
      defaultSopsFile = lib.snowfall.fs.get-file "modules/home/secrets.yaml";
      defaultSopsFormat = "yaml";

      gnupg.home = "/home/${config.snowfallorg.user.name}/.gnupg";
    };
  };
}
