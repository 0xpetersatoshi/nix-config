{
  lib,
  config,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.programs.guis.common;
in {
  options.programs.guis.common = with types; {
    enable = mkBoolOpt false "Whether or not to enable common guis.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
      ];

      casks = [
        "keymapp"
        "slack"
      ];

      masApps = {
      };
    };
  };
}
