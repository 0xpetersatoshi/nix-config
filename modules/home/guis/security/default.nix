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
  cfg = config.guis.security;
in {
  options.guis.security = {
    enable = mkEnableOption "Enable security guis";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      openssl
      proton-pass
      yubioath-flutter
    ];
  };
}
