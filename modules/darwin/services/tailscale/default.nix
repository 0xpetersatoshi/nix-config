{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.services.${namespace}.tailscale;
in {
  options.services.${namespace}.tailscale = with types; {
    enable = mkBoolOpt false "Whether or not to enable homebrew.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tailscale
    ];
    services.tailscale = {
      enable = true;
    };
  };
}
