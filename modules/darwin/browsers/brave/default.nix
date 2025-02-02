{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.browsers.brave;
in {
  options.browsers.brave = with types; {
    enable = mkBoolOpt false "Whether or not to enable brave.";
  };

  config = mkIf cfg.enable {
    homebrew.casks = ["brave-browser"];
  };
}
