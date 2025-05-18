{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.services.${namespace}.keybase;
in {
  options.services.${namespace}.keybase = {
    enable = mkEnableOption "Enable the keybase service";
  };

  config = mkIf cfg.enable {
    services = {
      keybase.enable = true;
      kbfs.enable = true;
    };

    environment.systemPackages = with pkgs; [
      keybase-gui
    ];
  };
}
