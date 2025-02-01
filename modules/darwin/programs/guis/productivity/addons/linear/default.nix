{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.programs.guis.productivity.addons.linear;
in {
  options.programs.guis.productivity.addons.linear = with types; {
    enable = mkBoolOpt false "Whether or not to enable linear app gui.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
      ];

      casks = [
        "linear-linear"
      ];

      masApps = {
      };
    };
  };
}
