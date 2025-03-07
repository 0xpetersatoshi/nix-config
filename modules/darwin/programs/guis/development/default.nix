{
  lib,
  config,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.programs.guis.development;
in {
  options.programs.guis.development = with types; {
    enable = mkBoolOpt false "Whether or not to enable development-focused guis.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
      ];

      brews = [
        "podman"
        "podman-compose"
        "podman-tui"
        "xcodegen"
      ];

      casks = [
        "ghostty"
        "podman-desktop"
        "visual-studio-code"
      ];

      masApps = {
        "Xcode" = 497799835;
      };
    };
  };
}
