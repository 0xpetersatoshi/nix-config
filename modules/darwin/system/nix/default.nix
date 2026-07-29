{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.system.nix;
in {
  options.system.nix = with types; {
    enable = mkBoolOpt false "Whether or not to manage nix settings via nix.custom.conf";
  };

  config = mkIf cfg.enable {
    # Determinate Nix owns /etc/nix/nix.conf; custom settings belong in nix.custom.conf
    environment.etc."nix/nix.custom.conf" = {
      text = ''
        extra-substituters = https://devenv.cachix.org
        extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
      '';
      knownSha256Hashes = [
        # default file written by the Determinate nix-installer
        "3bd68ef979a42070a44f8d82c205cfd8e8cca425d91253ec2c10a88179bb34aa"
      ];
    };
  };
}
