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
  cfg = config.guis.web3.wallets;
in {
  options.guis.web3.wallets = {
    enable = mkEnableOption "Enable desktop wallet guis";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ledger-live-desktop
      trezor-suite
    ];
  };
}
