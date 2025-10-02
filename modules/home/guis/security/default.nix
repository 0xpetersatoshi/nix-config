{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
with types; let
  cfg = config.guis.security;
in {
  options.guis.security = {
    enable = mkEnableOption "Enable security guis";
    _1password-gui.package = mkPackageOpt pkgs._1password-gui "Package to use for password manager";
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg._1password-gui.package
      pkgs.openssl
      pkgs.proton-pass
      # NOTE: need to fallback to stable package until python313Packages.fido2 v2.0.0 is released as there is
      # a bug in fido2 1.2.0 that breaks yubioath-flutter
      pkgs.yubioath-flutter
    ];
  };
}
