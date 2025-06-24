{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.terminals.alacritty;
  tokyonight-moon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/alacritty/tokyonight_moon.toml";
    sha256 = "sha256-HNrprH4KtXo4maNXLgwu68Gzf1bmXVj9YCo0dthcejU=";
  };
in {
  options.cli.terminals.alacritty = with types; {
    enable = mkBoolOpt false "enable alacritty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;

      settings = {
        general = {
          import = [tokyonight-moon];
        };
        terminal = {
          shell = {
            program = "zsh";
          };
        };

        cursor = {
          style = {
            shape = "Block";
          };
        };

        font = {
          size = config.stylix.fonts.sizes.terminal;

          offset = {
            x = 0;
            y = 0;
          };

          glyph_offset = {
            x = 0;
            y = 1;
          };

          normal = {
            family = lib.mkDefault config.stylix.fonts.monospace.name;
            style = lib.mkDefault "Bold";
          };
          bold = {
            family = lib.mkDefault config.stylix.fonts.monospace.name;
            style = "Bold";
          };
          italic = {
            family = lib.mkDefault config.stylix.fonts.monospace.name;
            style = "italic";
          };
          bold_italic = {
            family = lib.mkDefault config.stylix.fonts.monospace.name;
            style = "bold_italic";
          };
        };

        window = {
          dimensions = {
            columns = 0;
            lines = 0;
          };

          padding = {
            x = 10;
            y = 10;
          };

          decorations = "None";

          dynamic_padding = true;
          dynamic_title = true;
          # opacity = 0.98;
        };

        selection = {
          save_to_clipboard = true;
        };

        keyboard = {
          bindings = [
            {
              key = "T";
              mods = "Control";
              action = "SpawnNewInstance";
            }
            # Send literal newline without executing command (emulate alt+enter)
            {
              key = "Return";
              mods = "Shift";
              chars = "\\u001b\\r";
            }
          ];
        };

        mouse = {
          bindings = [
            {
              mouse = "Right";
              action = "Paste";
            }
          ];
        };

        env = {
          TERM = "xterm-256color";
        };
      };
    };
  };
}
