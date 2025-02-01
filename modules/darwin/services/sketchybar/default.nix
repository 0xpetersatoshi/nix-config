{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.${namespace}.sketchybar;
in {
  options.services.${namespace}.sketchybar = with types; {
    enable = mkBoolOpt false "Whether or not to enable sketchybar.";
  };

  config = mkIf cfg.enable {
    # NOTE: as this service does not currently have support for
    # complex configuration, we simply enable it here but the
    # config files are managed by home-manager in the sketchybar module
    services.sketchybar = {
      enable = true;
    };
  };
}
