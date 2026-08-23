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
    security.pam.services = {
      ${config.user.name}.kwallet = {
        enable = true;
        package = pkgs.kdePackages.kwallet-pam;
      };

      # Unlocks the wallet with the login password at the greeter, so the
      # session never prompts for it separately.
      sddm = mkIf config.services.displayManager.sddm.enable {
        kwallet = {
          enable = true;
          package = pkgs.kdePackages.kwallet-pam;
          forceRun = true;
        };
      };
    };
  };
}
