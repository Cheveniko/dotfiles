-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Color scheme
config.color_scheme = "Catppuccin Mocha"

-- Start wezterm in a fullscreen window
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():toggle_fullscreen()
end)

config.native_macos_fullscreen_mode = true

-- Disable top tab bar
config.enable_tab_bar = false

-- Font configuration
config.font_size = 14.0

config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono NF", weight = "Regular" },
	"Apple Color Emoji",
})

-- Make fonts look better
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"
config.freetype_load_flags = "NO_HINTING"
-- Keep the original renderer and font appearance.
config.front_end = "OpenGL"

-- Enable option (alt) keys
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- Window padding
config.window_padding = {
	left = "0cell",
	right = "1cell",
	top = "0.5cell",
	bottom = "0cell",
}

config.enable_kitty_graphics = true

local act = wezterm.action

config.keys = {
	-- Let OpenCode receive Ctrl+Tab instead of switching WezTerm tabs.
	{ key = "Tab", mods = "CTRL", action = act.DisableDefaultAssignment },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-0.5) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(0.5) },
	{ key = "LeftArrow", mods = "CMD", action = act({ SendString = "\x1bb" }) },
	{ key = "RightArrow", mods = "CMD", action = act({ SendString = "\x1bf" }) },
	{ key = "LeftArrow", mods = "SHIFT|CMD", action = act.MoveTabRelative(-1) },
	{ key = "RightArrow", mods = "SHIFT|CMD", action = act.MoveTabRelative(1) },
}

return config
