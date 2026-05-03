{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cli.terminals.kitty;
  tokyonight-moon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/folke/tokyonight.nvim/cdc07ac78467a233fd62c493de29a17e0cf2b2b6/extras/kitty/tokyonight_moon.conf";
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

      # On Darwin the .app bundle from the Nix package is not linked into
      # /Applications, so install via homebrew instead and let home-manager
      # only manage the config file.
      package = lib.mkIf pkgs.stdenv.isDarwin null;

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

        # Treat macOS Option as Alt so alt+hjkl reaches zellij/tmux.
        # Ignored on non-macOS.
        macos_option_as_alt = "yes";

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
        # Send literal newline without executing command (emulate alt+enter)
        "shift+enter" = "send_text all \\x1b\\x0d";
      };
    };
  };
}
