{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.security.gnupg;
in {
  options.security.gnupg = with types; {
    enable = mkBoolOpt false "Whether to enable gnupg for auth.";
  };

  config = mkIf cfg.enable {
    programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
  };
}
