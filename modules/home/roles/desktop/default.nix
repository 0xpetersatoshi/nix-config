{
  lib,
  config,
  ...
}: let
  cfg = config.roles.desktop;
in {
  options.roles.desktop = {
    enable = lib.mkEnableOption "Enable desktop configuration";
  };

  config = lib.mkIf cfg.enable {
    desktops.addons.xdg.enable = true;

    guis = {
      chat.enable = true;
    };
  };
}
