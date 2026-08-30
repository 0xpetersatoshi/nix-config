{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.desktop.addons.kwallet;
in {
  options.roles.desktop.addons.kwallet = with types; {
    enable = mkBoolOpt false "Enable or disable kwallet as the secret store.";
  };

  # kwallet is a standalone Qt secret store -- it does not need plasma. It backs
  # the Secret xdg portal and element-desktop's --password-store=kwallet6.
  config = mkIf cfg.enable {
    # Installs org.kde.secretservicecompat.service, which dbus-activates ksecretd
    # -- the org.freedesktop.secrets provider. kwalletd6 does NOT provide it, and
    # without it libsecret clients (1Password's 2FA token) cannot persist secrets.
    environment.systemPackages = [pkgs.kdePackages.kwallet];

    # Unlocks the wallet with the login password. This must live on the "login"
    # PAM service, not "sddm": the sddm service is defined via a literal `text`
    # ("auth substack login" ...) which overrides generated options like
    # kwallet.enable, but it substacks login -- so kwallet runs from there.
    # (This is also what services.desktopManager.plasma6 does.)
    security.pam.services.login = {
      kwallet = {
        enable = true;
        package = pkgs.kdePackages.kwallet-pam;
      };

      # The wallet key is derived from the typed login password. fprintd is
      # auto-added to every PAM service as "sufficient" ahead of the password
      # modules, so a fingerprint login skips them and the wallet prompts
      # anyway. Force password auth at login; fingerprint stays for
      # sudo/polkit/DMS lock (see security/fingerprint).
      fprintAuth = false;
    };
  };
}
