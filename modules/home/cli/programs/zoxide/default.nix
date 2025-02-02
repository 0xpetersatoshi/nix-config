{
  config,
  lib,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.programs.zoxide;
in {
  options.cli.programs.zoxide = with types; {
    enable = mkBoolOpt false "Whether or not to enable zoxide";
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      options = ["--cmd cd"];
    };
  };
}
