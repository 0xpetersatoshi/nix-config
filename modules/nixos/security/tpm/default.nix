{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.security.tpm;
in {
  options.security.tpm = with types; {
    enable = mkBoolOpt false "Whether to enable tpm support.";
  };

  config = mkIf cfg.enable {
    security.tpm2 = {
      enable = true;
      pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
      tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
      abrmd.enable = true;
    };
    users.users.${config.user.name}.extraGroups = ["tss"]; # tss group has access to TPM devices
  };
}
