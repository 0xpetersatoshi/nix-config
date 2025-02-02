{
  lib,
  config,
  ...
}: let
  cfg = config.roles.browsers;
in {
  options.roles.browsers = {
    enable = lib.mkEnableOption "Enable browsers guis";
  };

  config = lib.mkIf cfg.enable {
    browsers.brave.enable = true;
    browsers.chrome.enable = true;
    browsers.firefox.enable = true;
    browsers.zen.enable = true;
  };
}
