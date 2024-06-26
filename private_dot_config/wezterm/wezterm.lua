local wezterm = require("wezterm")
local mux = wezterm.mux

local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#000000"

return {
	color_schemes = {
		["OLEDppuccin"] = custom,
	},
	color_scheme = "OLEDppuccin",
	enable_tab_bar = false,
	font = wezterm.font("FiraCode Nerd Font Mono"),
	font_size = 18.0,
	macos_window_background_blur = 30,

	-- window_background_opacity = 0.7,
	-- text_background_opacity = 0.7,
	-- window_background_opacity = 0.4,
	-- text_background_opacity = 0.5,
	window_background_opacity = 0.8,
	text_background_opacity = 0.8,
	window_decorations = "RESIZE",

	window_close_confirmation = "NeverPrompt",

	keys = {
		-- pane creation
		{ key = "h", mods = "CMD", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
		{ key = "d", mods = "CMD", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
		{
			key = "x",
			mods = "CMD",
			action = wezterm.action({ CloseCurrentPane = { domain = "CurrentPaneDomain", confirm = true } }),
		},
		-- -- Make Option-h equivalent to Alt-b which many line editors interpret as backward-word
		-- { key = "h", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
		-- -- Make Option-l equivalent to Alt-f; forward-word
		-- { key = "l", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
	},
	mouse_bindings = {
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
	},
}
