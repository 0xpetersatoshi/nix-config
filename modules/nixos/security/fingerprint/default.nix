{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.security.fingerprint;

  # Exits 0 only when a laptop lid reports "closed". PAM uses this to skip the
  # fingerprint prompt when the reader (embedded in the power button) is
  # physically unreachable, so auth falls straight through to the password.
  lidClosedCheck = pkgs.writeShellScript "pam-lid-closed" ''
    ${pkgs.gnugrep}/bin/grep -qi closed /proc/acpi/button/lid/*/state
  '';

  # fprintd is auto-added to every PAM service (fprintAuth defaults to
  # services.fprintd.enable). Pin it ahead of pam_unix and gate it on the lid
  # check so it is the only factor tried when usable and silently skipped when
  # the lid is closed.
  fingerprintFirstRules = {
    # On success (lid closed) jump over the next rule (fprintd) to the password.
    lidClosed = {
      order = 10750;
      control = "[success=1 default=ignore]";
      modulePath = "${pkgs.pam}/lib/security/pam_exec.so";
      args = ["quiet" "${lidClosedCheck}"];
    };
    # Keep fingerprint ahead of the password (pam_unix, order 11700).
    fprintd.order = mkForce 10800;
  };
in {
  options.${namespace}.security.fingerprint = with types; {
    enable = mkBoolOpt false "Use the fingerprint reader for system auth, with password fallback (auto when the lid is closed).";
    services = mkOpt (listOf str) ["sudo" "polkit-1"] "PAM services to make fingerprint-first (1Password unlocks via polkit-1).";
  };

  config = mkIf cfg.enable {
    services.fprintd.enable = true;

    security.pam = {
      # The reader is the only token this host authenticates with, so drop
      # pam_u2f everywhere: every PAM service inherits it from u2f.enable, which
      # would otherwise leave sudo/polkit prompting for a YubiKey touch after a
      # failed or absent fingerprint.
      u2f.enable = mkForce false;

      services = genAttrs cfg.services (_: {
        fprintAuth = true;
        rules.auth = fingerprintFirstRules;
      });
    };
  };
}
