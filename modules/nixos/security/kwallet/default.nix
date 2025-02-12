{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.security.kwalletAutoUnlock;
in {
  options.security.kwalletAutoUnlock = with types; {
    enable = mkBoolOpt false "Whether to enable kwallet to unlock on login.";
  };

  config = mkIf cfg.enable {
    security.pam.services = {
      sddm = {
        kwallet = {
          enable = true;
          package = pkgs.kdePackages.kwallet-pam;
        };
        text = ''
          auth      substack      login
          account   include       login
          password  substack      login
          session   include       login

          auth     optional     ${pkgs.kdePackages.kwallet-pam}/lib/security/pam_kwallet5.so
          session  optional     ${pkgs.kdePackages.kwallet-pam}/lib/security/pam_kwallet5.so auto_start
        '';
      };
    };

    environment.systemPackages = with pkgs; [
      kdePackages.kwallet
      kdePackages.kwallet-pam
    ];
  };
}
