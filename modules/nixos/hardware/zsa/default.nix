{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.hardware.${namespace}.zsa;
in {
  options.hardware.${namespace}.zsa = with types; {
    enable = mkBoolOpt false "Enable ZSA Keyboard";
  };

  config = mkIf cfg.enable {
    hardware.keyboard.zsa.enable = true;
  };
}
