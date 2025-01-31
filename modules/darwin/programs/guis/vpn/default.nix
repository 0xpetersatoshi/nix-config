{
  lib,
  config,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.programs.guis.vpn;
in {
  options.programs.guis.vpn = with types; {
    enable = mkBoolOpt false "Whether or not to enable vpn-focused guis.";
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [
        "tailscale"
      ];

      casks = [
      ];

      masApps = {
        "Wireguard" = 1451685025;
      };
    };
  };
}
