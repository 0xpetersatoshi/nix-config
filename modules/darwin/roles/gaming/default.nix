{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.gaming;
in {
  options.roles.gaming = with types; {
    enable = mkBoolOpt false "Whether or not to enable gaming-focused guis.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
      ];

      casks = [
        "steam"
      ];

      masApps = {
      };
    };
  };
}
