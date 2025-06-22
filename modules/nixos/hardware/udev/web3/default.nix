{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.${namespace}.udev.web3;
in {
  options.hardware.${namespace}.udev.web3 = with types; {
    enable = mkBoolOpt false "Enable or disable web3 udev rules";
  };

  config = mkIf cfg.enable {
    hardware.ledger.enable = true;
  };
}
