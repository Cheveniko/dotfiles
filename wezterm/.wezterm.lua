-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Color scheme
config.color_scheme = "Catppuccin Mocha"

-- Start wezterm in a maximized window (no native fullscreen Space)
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- Hide the title bar but keep the window resizable
config.window_decorations = "RESIZE"

-- Disable tab bar
config.enable_tab_bar = false

-- Longer scrollback for logs and agent output
config.scrollback_lines = 20000

-- Font configuration
config.font_size = 14.0
config.font_dirs = { wezterm.home_dir .. "/Library/Fonts" }

config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono Nerd Font", weight = "Regular" },
	"Apple Color Emoji",
})

-- Make fonts look better
-- Retina display: no subpixel (LCD) antialiasing or hinting needed
config.freetype_load_target = "Light"
config.freetype_load_flags = "NO_HINTING"

-- Render through Metal (WebGpu) at the ProMotion display's 120Hz
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.max_fps = 120

-- Left option acts as Meta, right option types special characters (á, ñ, ¿...)
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Window padding
config.window_padding = {
	left = "6pt",
	right = "6pt",
	top = "6pt",
	bottom = "6pt",
}

config.enable_kitty_graphics = true

local act = wezterm.action

config.keys = {
	-- Let OpenCode receive Ctrl+Tab instead of switching WezTerm tabs.
	{ key = "Tab", mods = "CTRL", action = act.DisableDefaultAssignment },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-0.5) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(0.5) },
	-- macOS-style editing: option moves by word, cmd jumps to line start/end.
	{ key = "LeftArrow", mods = "OPT", action = act({ SendString = "\x1bb" }) },
	{ key = "RightArrow", mods = "OPT", action = act({ SendString = "\x1bf" }) },
	{ key = "LeftArrow", mods = "CMD", action = act({ SendString = "\x01" }) },
	{ key = "RightArrow", mods = "CMD", action = act({ SendString = "\x05" }) },
	{ key = "Backspace", mods = "CMD", action = act({ SendString = "\x15" }) },
	{ key = "LeftArrow", mods = "SHIFT|CMD", action = act.MoveTabRelative(-1) },
	{ key = "RightArrow", mods = "SHIFT|CMD", action = act.MoveTabRelative(1) },
}

return config
