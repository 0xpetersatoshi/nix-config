{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
with types; let
  cfg = config.guis.chat;
in {
  options.guis.chat = {
    enable = mkEnableOption "Enable chat guis";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      discord
      slack
      telegram-desktop
      whatsapp-for-linux
    ];
  };
}
