{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.programs.guis.social;
in {
  options.programs.guis.social = with types; {
    enable = mkBoolOpt false "Whether or not to enable social-focused guis.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
      ];

      casks = [
        "discord"
        "signal"
        "telegram"
        "whatsapp"
      ];

      masApps = {
      };
    };
  };
}
