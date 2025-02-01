{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.roles.disk-utilities;
in {
  options.roles.disk-utilities = with types; {
    enable = mkBoolOpt false "Whether or not to enable disk-utility guis.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
      ];

      casks = [
        "balenaetcher"
      ];

      masApps = {
        "AmorphousDiskMark" = 1168254295;
        "Disk Speed Test" = 425264550;
      };
    };
  };
}
