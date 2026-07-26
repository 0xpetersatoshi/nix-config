{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.multiplexers.herdr;
  inherit (config.lib.stylix) colors;
in {
  options.cli.multiplexers.herdr = with types; {
    enable = mkBoolOpt false "enable herdr multiplexer";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.herdr];
    xdg.configFile."herdr/config.toml".text = let
      bases = ["base00" "base01" "base05" "base08" "base09" "base0A" "base0B" "base0C" "base0D" "base0E"];
    in
      builtins.replaceStrings
      (map (b: "@${b}@") bases)
      (map (b: colors.${b}) bases)
      (builtins.readFile ./config.toml);
  };
}
