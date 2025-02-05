{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.security.kwallet;
in {
  options.security.kwallet = with types; {
    enable = mkBoolOpt false "Whether to enable kwallet for auth.";
  };

  config = mkIf cfg.enable {
    security.pam.services = {
    kwallet = {
      name = "kwallet";
      enableKwallet = true;
    };

    login = {
      enableKwallet = true;
    };
  };
  };
}
