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
  cfg = config.security._1password-gui;
in {
  options.security._1password-gui = {
    enable = mkEnableOption "Enable 1password gui";
    package-gui = mkPackageOpt pkgs.unstable._1password-gui "Package to use for password manager";
  };

  config = mkIf cfg.enable {
    programs = {
      _1password-gui = {
        enable = true;
        package = cfg.package-gui;
        polkitPolicyOwners = [config.user.name];
      };

      _1password = {
        enable = true;
        package = pkgs.unstable._1password-cli;
      };
    };
  };
}
