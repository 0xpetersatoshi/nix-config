{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.music;
in {
  options.roles.music = with types; {
    enable = mkBoolOpt false "Whether or not to enable music-focused guis.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
      ];

      casks = [
        "spotify"
      ];

      masApps = {
      };
    };
  };
}
