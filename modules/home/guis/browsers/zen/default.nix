{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
with types; let
  cfg = config.guis.browsers.zen;
in {
  options.guis.browsers.zen = {
    enable = mkEnableOption "Enable zen browser";
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.zen-browser.packages."${pkgs.system}".default
    ];
  };
}
