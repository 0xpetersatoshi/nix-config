{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cli.terminals.ghostty;
in {
  options.cli.terminals.ghostty = {
    enable = mkEnableOption "enable ghostty terminal emulator";
  };

  config = mkIf cfg.enable {
    xdg.configFile."ghostty/config".source = mkForce ./config;

    programs.ghostty = {
      # NOTE: this is currently broken on darwin
      # temporarily managed by homebrew but need the
      # config file to be set above when enabled
      enable = !pkgs.stdenv.isDarwin;
      enableZshIntegration = false;
    };
  };
}
