{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
with types; let
  cfg = config.security._1password-browser-integration;
in {
  options.security._1password-browser-integration = {
    enable = mkEnableOption "Enable 1password gui";
  };

  config = mkIf cfg.enable {
    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          .zen-wrapped
        '';
        mode = "0755";
      };
    };
  };
}
