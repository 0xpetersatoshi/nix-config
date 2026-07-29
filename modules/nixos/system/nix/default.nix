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
        trusted-users = ["@wheel" "root"];
        auto-optimise-store = lib.mkDefault true;
        use-xdg-base-directories = true;
        experimental-features = ["nix-command" "flakes"];
        extra-substituters = ["https://devenv.cachix.org"];
        extra-trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="];
        warn-dirty = false;
        system-features = ["kvm" "big-parallel" "nixos-test"];
      };
    };
  };
}
