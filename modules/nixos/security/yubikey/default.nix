{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.security.yubikey;
in {
  options.security.yubikey = with types; {
    enable = mkBoolOpt false "Whether to enable yubikey for auth.";
  };

  config = mkIf cfg.enable {
    services = {
      pcscd.enable = true;
      udev.packages = with pkgs; [yubikey-personalization];
      dbus.packages = [pkgs.gcr];
    };

    security.pam.services = {
      sudo = {
        u2fAuth = true;
      };
    };

    programs.yubikey-touch-detector.enable = true;
  };
}
