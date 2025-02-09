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
    _1password-gui.package = mkPackageOpt pkgs.unstable._1password-gui "Package to use for password manager";
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg._1password-gui.package
      pkgs.yubioath-flutter
    ];
  };
}
