{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.programs.network-tools;
in {
  options.cli.programs.network-tools = with types; {
    enable = mkBoolOpt false "Whether or not to enable network tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        tshark
        termshark
        kubeshark
      ]
      ++ (
        if pkgs.stdenv.isLinux
        then [ethtool]
        else []
      );
  };
}
