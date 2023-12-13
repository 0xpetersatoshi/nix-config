-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- color config
config.color_scheme = "Dark One Nuanced Custom"

-- font config
-- config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Bold", italic = false })
config.font = wezterm.font_with_fallback({
	{ family = "JetBrains Mono", weight = "Bold", italic = false },
	"Apple Color Emoji",
})
config.font_size = 14.0

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
	{ key = "f", mods = "CTRL", action = wezterm.action.ToggleFullScreen },
}

-- and finally, return the configuration to wezterm
return config
