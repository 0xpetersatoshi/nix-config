{
  lib,
  config,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.programs.guis.security;
in {
  options.programs.guis.security = with types; {
    enable = mkBoolOpt false "Whether or not to enable security-focused guis.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
      ];

      casks = [
        "1password"
        "yubico-authenticator"
      ];

      masApps = {
        "1Password for Safari" = 1569813296;
      };
    };
  };
}
