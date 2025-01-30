{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cli.terminals.ghostty;
in {
  options.cli.terminals.ghostty = {
    enable = mkEnableOption "enable ghostty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
