{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cli.terminals.wezterm;
  inherit (config.lib.stylix) colors;
in {
  options.cli.terminals.wezterm = {
    enable = mkEnableOption "enable wezterm terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = ''
                -- Pull in the wezterm API
        local wezterm = require("wezterm")

        -- This table will hold the configuration.
        local config = {}

        local act = wezterm.action

        -- In newer versions of wezterm, use the config_builder which will
        -- help provide clearer error messages
        if wezterm.config_builder then
        	config = wezterm.config_builder()
        end

        -- color config
        config.color_scheme = "Catppuccin Macchiato"

        -- font config
        -- config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Bold", italic = false })
        config.font = wezterm.font_with_fallback({
        	{ family = "${config.stylix.fonts.monospace.name}", weight = "Bold", italic = false },
        	"Apple Color Emoji",
        })
        config.font_size = 14

        -- tab config
        config.hide_tab_bar_if_only_one_tab = true

        -- window config
        config.macos_window_background_blur = 30
        config.window_background_opacity = 1.0
        config.window_decorations = "RESIZE"

        -- cursor config
        config.cursor_blink_rate = 750
        config.default_cursor_style = "BlinkingBlock"

        -- keybindings
        config.keys = {
        	-- CMD + CTRL bindings
        	{
        		key = "f",
        		mods = "CMD|CTRL",
        		action = act.ToggleFullScreen,
        	},
        	-- OPT bindings
        	-- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
        	{
        		key = "LeftArrow",
        		mods = "OPT",
        		action = act.SendKey({
        			key = "b",
        			mods = "ALT",
        		}),
        	},
        	{
        		key = "RightArrow",
        		mods = "OPT",
        		action = act.SendKey({
        			key = "f",
        			mods = "ALT",
        		}),
        	},
        	-- Rebind OPT-HJKL to send to tmux for rezising panes
        	{
        		key = "h",
        		mods = "ALT",
        		action = act.SendKey({
        			key = "h",
        			mods = "ALT",
        		}),
        	},
        	{
        		key = "j",
        		mods = "ALT",
        		action = act.SendKey({
        			key = "j",
        			mods = "ALT",
        		}),
        	},
        	{
        		key = "k",
        		mods = "ALT",
        		action = act.SendKey({
        			key = "k",
        			mods = "ALT",
        		}),
        	},
        	{
        		key = "l",
        		mods = "ALT",
        		action = act.SendKey({
        			key = "l",
        			mods = "ALT",
        		}),
        	},
        	-- CMD bindings
        	-- Bind Cmd + Left to move the cursor to the beginning of the line
        	{
        		key = "LeftArrow",
        		mods = "CMD",
        		action = act.SendString("\027[H"),
        	},
        	-- Bind Cmd + Right to move the cursor to the end of the line
        	{
        		key = "RightArrow",
        		mods = "CMD",
        		action = act.SendString("\027[F"),
        	},
        }

        -- mouse bindings
        config.mouse_bindings = {
        	-- Change the default click behavior so that it only selects
        	-- text and doesn't open hyperlinks
        	{
        		event = { Up = { streak = 1, button = "Left" } },
        		mods = "NONE",
        		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
        	},

        	-- and make CTRL-Click open hyperlinks
        	{
        		event = { Up = { streak = 1, button = "Left" } },
        		mods = "CMD",
        		action = act.OpenLinkAtMouseCursor,
        	},

        	-- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
        	{
        		event = { Down = { streak = 1, button = "Left" } },
        		mods = "CMD",
        		action = act.Nop,
        	},
        }

        -- and finally, return the configuration to wezterm
        return config
      '';

      # colorSchemes = {
      #   stylix = {
      #     ansi = [
      #       "#${colors.base01}"
      #       "#${colors.base08}"
      #       "#${colors.base0B}"
      #       "#${colors.base09}"
      #       "#${colors.base0D}"
      #       "#${colors.base0E}"
      #       "#${colors.base0C}"
      #       "#${colors.base05}"
      #     ];
      #     brights = [
      #       "#${colors.base03}"
      #       "#${colors.base08}"
      #       "#${colors.base0B}"
      #       "#${colors.base09}"
      #       "#${colors.base0D}"
      #       "#${colors.base0E}"
      #       "#${colors.base0C}"
      #       "#${colors.base07}"
      #     ];
      #     background = "#${colors.base00}";
      #     foreground = "#${colors.base05}";
      #     cursor_bg = "#${colors.base0B}";
      #     cursor_border = "#${colors.base0B}";
      #     cursor_fg = "#${colors.base00}";
      #     compose_cursor = "#${colors.base08}";
      #     selection_bg = "#${colors.base02}";
      #     selection_fg = "#${colors.base05}";
      #     scrollbar_thumb = "#${colors.base02}";
      #     split = "#${colors.base02}";
      #     visual_bell = "#${colors.base02}";
      #   };
      # };
    };
  };
}
