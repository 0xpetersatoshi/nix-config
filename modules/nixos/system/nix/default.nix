{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.system.nix;
in {
  options.system.nix = with types; {
    enable = mkBoolOpt false "Whether or not to manage nix configuration";
  };

  config = mkIf cfg.enable {
    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
      };
    };
  };
}
