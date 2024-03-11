local wezterm = require("wezterm")

return {
	-- appearance
	color_scheme = "Catppuccin Mocha",
	enable_tab_bar = false,
	font = wezterm.font("FiraCode Nerd Font Mono"),
	font_size = 16.0,
	macos_window_background_blur = 30,

	-- window_background_opacity = 0.55,
	-- text_background_opacity = 0.55,
	window_background_opacity = 0.7,
	text_background_opacity = 0.7,
	window_decorations = "RESIZE",

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
