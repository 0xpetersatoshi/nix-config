{
  lib,
  config,
  ...
}: let
  cfg = config.roles.common;
in {
  options.roles.common = {
    enable = lib.mkEnableOption "Enable common configuration guis";
  };

  config = lib.mkIf cfg.enable {
    package-managers.homebrew.enable = true;
    browsers.chrome.enable = true;
    programs.guis.common.enable = true;
  };
}
