{
  config,
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
      login = {
        kwallet.enable = true;
      };
    };
  };
}
