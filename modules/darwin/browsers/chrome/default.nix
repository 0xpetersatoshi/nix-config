{
  lib,
  config,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.browsers.chrome;
in {
  options.browsers.chrome = with types; {
    enable = mkBoolOpt false "Whether or not to enable chrome.";
  };

  config = mkIf cfg.enable {
    homebrew.casks = [ "google-chrome" ];
  };
}
