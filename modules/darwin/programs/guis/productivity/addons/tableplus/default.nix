{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.programs.guis.productivity.addons.tableplus;
in {
  options.programs.guis.productivity.addons.tableplus = with types; {
    enable = mkBoolOpt false "Whether or not to enable tableplus gui.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
      ];

      casks = [
        "tableplus"
      ];

      masApps = {
      };
    };
  };
}
