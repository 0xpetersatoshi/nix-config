{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.browsers.zen;
in {
  options.browsers.zen = with types; {
    enable = mkBoolOpt false "Whether or not to enable zen.";
  };

  config = mkIf cfg.enable {
    homebrew.casks = ["zen-browser"];
  };
}
