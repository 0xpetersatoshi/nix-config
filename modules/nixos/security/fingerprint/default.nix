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
  # physically unreachable, so auth falls straight through to the YubiKey.
  lidClosedCheck = pkgs.writeShellScript "pam-lid-closed" ''
    ${pkgs.gnugrep}/bin/grep -qi closed /proc/acpi/button/lid/*/state
  '';

  # fprintd is auto-added to every PAM service (fprintAuth defaults to
  # services.fprintd.enable) but lands after pam_u2f (order 10900). Pull it in
  # front of the YubiKey and gate it on the lid check so it is preferred when
  # usable and silently skipped when the lid is closed.
  fingerprintFirstRules = {
    # On success (lid closed) jump over the next rule (fprintd) to pam_u2f.
    lidClosed = {
      order = 10750;
      control = "[success=1 default=ignore]";
      modulePath = "${pkgs.pam}/lib/security/pam_exec.so";
      args = ["quiet" "${lidClosedCheck}"];
    };
    # Move fingerprint ahead of the YubiKey (pam_u2f, order 10900).
    fprintd.order = mkForce 10800;
  };
in {
  options.${namespace}.security.fingerprint = with types; {
    enable = mkBoolOpt false "Prefer the fingerprint reader for auth, with YubiKey/password fallback (auto when the lid is closed).";
    services = mkOpt (listOf str) ["sudo" "polkit-1"] "PAM services to make fingerprint-first (1Password unlocks via polkit-1).";
  };

  config = mkIf cfg.enable {
    services.fprintd.enable = true;

    security.pam.services = genAttrs cfg.services (_: {
      fprintAuth = true;
      rules.auth = fingerprintFirstRules;
    });
  };
}
