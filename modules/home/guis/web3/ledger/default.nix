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
  cfg = config.guis.web3.ledger;
in {
  options.guis.web3.ledger = {
    enable = mkEnableOption "Enable ledger live desktop gui";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ledger-live-desktop
    ];
  };
}
