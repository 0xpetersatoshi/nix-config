{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cli.terminals.kitty;
  tokyonight-moon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/kitty/tokyonight_moon.conf";
    sha256 = "sha256-F2mcDp1HI/RLRjEpAABRCfrCsJTcEhbsUE02bTKEBDA=";
  };
in {
  options.cli.terminals.kitty = {
    enable = mkEnableOption "enable kitty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;

      font = {
        name = config.stylix.fonts.monospace.name;
        size = config.stylix.fonts.sizes.terminal;
      };

      settings = {
        # Theme
        include = "${tokyonight-moon}";

        # Cursor
        cursor_shape = "block";

        # Copy on select
        copy_on_select = "yes";

        # Background
        # background_opacity = "0.95";
        # background_blur = "20";
      };

      keybindings = {
        "ctrl+t" = "new_tab";
        "ctrl+shift+t" = "no_op";
        "alt+left" = "send_text all \x1bb";
        "alt+right" = "send_text all \x1bf";
        "super+left" = "send_text all \x1b[H";
        "super+right" = "send_text all \x1b[F";
      };
    };
  };
}
