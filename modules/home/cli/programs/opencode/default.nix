{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.programs.opencode;
in {
  options.cli.programs.opencode = with types; {
    enable = mkBoolOpt false "Whether or not to enable opencode";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.${namespace}.opencode
    ];

    xdg.configFile."opencode/.opencode.json".source = ./opencode.json;
  };
}
