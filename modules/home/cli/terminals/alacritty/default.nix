{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.igloo; let
  cfg = config.cli.terminals.alacritty;
in {
  options.cli.terminals.alacritty = with types; {
    enable = mkBoolOpt false "enable alacritty terminal emulator";
    font = {
      normal = mkOpt str (
        if pkgs.stdenv.hostPlatform.isDarwin
        then "Monaspace Neon"
        else "JetBrainsMono Nerd Font Mono"
      ) "Font to use for alacritty.";
      bold = mkOpt str (
        if pkgs.stdenv.hostPlatform.isDarwin
        then "Monaspace Xenon"
        else "JetBrainsMono Nerd Font Mono"
      ) "Font to use for alacritty.";
      italic = mkOpt str (
        if pkgs.stdenv.hostPlatform.isDarwin
        then "Monaspace Radon"
        else "JetBrainsMono Nerd Font Mono"
      ) "Font to use for alacritty.";
      bold_italic = mkOpt str (
        if pkgs.stdenv.hostPlatform.isDarwin
        then "Monaspace Krypton"
        else "JetBrainsMono Nerd Font Mono"
      ) "Font to use for alacritty.";
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;

      settings = {
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
          size = lib.mkDefault 14.0;

          offset = {
            x = 0;
            y = 0;
          };

          glyph_offset = {
            x = 0;
            y = 1;
          };

          normal = {
            family = lib.mkDefault cfg.font.normal;
          };
          bold = {
            family = lib.mkDefault cfg.font.bold;
            style = "Bold";
          };
          italic = {
            family = lib.mkDefault cfg.font.italic;
            style = "italic";
          };
          bold_italic = {
            family = lib.mkDefault cfg.font.bold_italic;
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

        mouse_bindings = [
          {
            mouse = "Right";
            action = "Paste";
          }
        ];

        env = {
          TERM = "xterm-256color";
        };
      };
    };
  };
}
