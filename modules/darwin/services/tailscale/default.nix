{
  lib,
  config,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.services.tailscale;
in {
  options.services.tailscale = with types; {
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
