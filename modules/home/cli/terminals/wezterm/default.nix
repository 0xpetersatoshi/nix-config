{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cli.terminals.wezterm;
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
    };
  };
}
