-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices
config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font("Hack", { weight = "Bold", italic = true })
--config.font = wezterm.font("JetBrains Mono", { weight = "Bold" })
config.font_size = 14.0

-- 'Dark One Nuanced' theme ported from kitty theme
config.colors = {
	ansi = {
		"#3f4451",
		"#ffffff",
		"#c8c8c8",
		"#d19a66",
		"#61afef",
		"#c678dd",
		"#56b6c2",
		"#e6e6e6",
	},
	brights = {
		"#4f5666",
		"#ff7b86",
		"#b1e18b",
		"#efb074",
		"#67cdff",
		"#e48bff",
		"#63d4e0",
		"#ffffff",
	},
	background = "#282c34",
	foreground = "#abb2bf",
}

config.enable_tab_bar = false

config.macos_window_background_blur = 30
config.window_background_opacity = 1.0
config.window_decorations = "RESIZE"

config.keys = {
	{ key = "f", mods = "CTRL", action = wezterm.action.ToggleFullScreen },
}

-- and finally, return the configuration to wezterm
return config
