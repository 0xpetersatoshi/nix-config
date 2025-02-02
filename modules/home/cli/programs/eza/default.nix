{
  config,
  lib,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.programs.eza;
in {
  options.cli.programs.eza = with types; {
    enable = mkBoolOpt false "Whether or not to enable eza";
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };
  };
}
