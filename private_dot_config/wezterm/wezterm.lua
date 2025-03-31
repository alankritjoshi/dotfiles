local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()
local act = wezterm.action

local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#000000"

config.color_schemes = {
	["OLEDppuccin"] = custom,
}
config.color_scheme = "OLEDppuccin"

-- config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
-- config.font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Medium" })
config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular", stretch = "Normal", style = "Normal" })
config.font_size = 23.0
config.macos_window_background_blur = 30

-- window_background_opacity = 0.7,
-- text_background_opacity = 0.7,
-- window_background_opacity = 0.4,
-- text_background_opacity = 0.5,
config.window_background_opacity = 0.9
config.text_background_opacity = 0.6
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.scrollback_lines = 10000

config.animation_fps = 120
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500

config.keys = {
	{
		key = ",",
		mods = "SUPER",
		action = act.SpawnCommandInNewWindow({
			cwd = os.getenv("WEZTERM_CONFIG_DIR"),
			args = { os.getenv("SHELL"), "-c", "$EDITOR $WEZTERM_CONFIG_FILE" },
		}),
	},
	-- pane creation
	{ key = "h", mods = "CMD", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "d", mods = "CMD", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{
		key = "x",
		mods = "CMD",
		action = wezterm.action({ CloseCurrentPane = { domain = "CurrentPaneDomain", confirm = true } }),
	},
	{
		key = "h",
		mods = "SHIFT|CTRL",
		action = wezterm.action.Nop,
	},
	{
		key = "j",
		mods = "SHIFT|CTRL",
		action = wezterm.action.Nop,
	},
	{
		key = "k",
		mods = "SHIFT|CTRL",
		action = wezterm.action.Nop,
	},
	{
		key = "l",
		mods = "SHIFT|CTRL",
		action = wezterm.action.Nop,
	},
	-- -- Make Option-h equivalent to Alt-b which many line editors interpret as backward-word
	-- { key = "h", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
	-- -- Make Option-l equivalent to Alt-f; forward-word
	-- { key = "l", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
}
config.mouse_bindings = {
	-- Change the default click behavior so that it only selects
	-- text and doesn't open hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action.CompleteSelection("PrimarySelection"),
	},
	-- Cmd-click will open the link under the mouse cursor
	-- NOTE: In zellij, it's Shift+Cmd-Click
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	-- Disable the 'Down' event of Cmd-Click to avoid weird program behaviors
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = wezterm.action.Nop,
	},
}

return config
