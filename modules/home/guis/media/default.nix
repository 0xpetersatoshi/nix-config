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
  cfg = config.guis.media;
in {
  options.guis.media = {
    enable = mkEnableOption "Enable media guis";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      darktable
      # davinci-resolve
      hugin
    ];
  };
}
