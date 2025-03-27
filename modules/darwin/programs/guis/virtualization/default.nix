{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.programs.guis.virtualization;
in {
  options.programs.guis.virtualization = with types; {
    enable = mkBoolOpt false "Whether or not to enable virtualization-focused guis.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
      ];

      casks = [
        "docker"
      ];

      masApps = {
      };
    };
  };
}
