{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cli.terminals.kitty;
in {
  options.cli.terminals.kitty = {
    enable = mkEnableOption "enable kitty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;

      font = {
        name = "${config.stylix.fonts.monospace.name}";
        size = config.stylix.fonts.sizes.terminal;
      };

      keybindings = {
        "alt+left" = "send_text all \x1bb";
        "alt+right" = "send_text all \x1bf";
        "super+left" = "send_text all \x1b[H";
        "super+right" = "send_text all \x1b[F";
      };

      themeFile = "Catppuccin-Mocha";
    };
  };
}
