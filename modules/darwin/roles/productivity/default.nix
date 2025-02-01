{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.productivity;
in {
  options.roles.productivity = with types; {
    enable = mkBoolOpt false "Whether or not to enable productivity-focused guis.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
      ];

      casks = [
        "logitech-options"
        "obsidian"
        "proton-mail"
        "raycast"
        "zoom"
      ];

      masApps = {
      };
    };
  };
}
