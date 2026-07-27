{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.cli.ai.cursor;
in {
  options.cli.ai.cursor = with types; {
    enable = mkBoolOpt false "Whether or not to enable the cursor cli";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.cursor-cli];

    home.file.".cursor/mcp.json".source = ./mcp.json;
  };
}
