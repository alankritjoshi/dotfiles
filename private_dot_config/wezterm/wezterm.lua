local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#000000"

config.color_schemes = {
	["OLEDppuccin"] = custom,
}
config.color_scheme = "OLEDppuccin"

-- config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false

-- config.font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Medium" })
config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular", stretch = "Normal", style = "Normal" })
config.font_size = 23.0
config.macos_window_background_blur = 30

-- config.window_background_opacity = 0.7
-- config.text_background_opacity = 0.7
config.window_background_opacity = 0.8
config.text_background_opacity = 0.7
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.scrollback_lines = 10000

config.animation_fps = 120
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500

config.leader = { key = "a", mods = "CTRL" }

config.keys = {
	-- {
	-- 	key = ",",
	-- 	mods = "SUPER",
	-- 	action = act.SpawnCommandInNewWindow({
	-- 		cwd = os.getenv("WEZTERM_CONFIG_DIR"),
	-- 		args = { os.getenv("SHELL"), "-c", "$EDITOR $WEZTERM_CONFIG_FILE" },
	-- 	}),
	-- },
	-- pane creation
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.Multiple({
			wezterm.action.SendKey({ key = "d", mods = "OPT" }),
			wezterm.action_callback(function(window, pane)
				wezterm.wait_for_ms(100)
			end),
			wezterm.action.CloseCurrentTab({ confirm = false }),
		}),
	},
	{
		key = "q",
		mods = "CMD",
		action = wezterm.action.Multiple({
			wezterm.action.SendKey({ key = "d", mods = "OPT" }),
			wezterm.action_callback(function(window, pane)
				wezterm.wait_for_ms(100)
			end),
			wezterm.action.CloseCurrentTab({ confirm = false }),
		}),
	},
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "x",
		mods = "LEADER",
		action = wezterm.action({
			CloseCurrentPane = { domain = "CurrentPaneDomain", confirm = false },
		}),
	},
	{
		key = "s",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|TABS" }),
	},
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
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

-- wezterm.on("gui-startup", function(cmd)
-- 	local tab, pane, window = mux.spawn_window(cmd or {})
-- 	window:gui_window():maximize()
-- end)

config.window_frame = {
	-- The font used in the tab bar.
	-- Roboto Bold is the default; this font is bundled
	-- with wezterm.
	-- Whatever font is selected here, it will have the
	-- main font setting appended to it to pick up any
	-- fallback fonts you may have used there.
	font = wezterm.font({ family = "Roboto", weight = "Bold" }),

	-- The size of the font in the tab bar.
	-- Default to 10.0 on Windows but 12.0 on other systems
	font_size = 12.0,

	-- The overall background color of the tab bar when
	-- the window is focused
	active_titlebar_bg = "#000000",

	-- The overall background color of the tab bar when
	-- the window is not focused
	inactive_titlebar_bg = "#000000",
}

wezterm.on("format-tab-title", function(tab, tabs, panes, _config, hover, max_width)
	local function tab_title(tab_info)
		local title = tab_info.tab_title
		-- if the tab title is explicitly set, take that
		if title and #title > 0 then
			return title
		end
		-- Otherwise, use the title from the active pane
		-- in that tab
		return tab_info.active_pane.title
	end

	local background = "#000000"
	local foreground = "#ffffff"

	if tab.is_active then
		background = "#94E59A"
		foreground = "#ffffff"
	end

	local title = tab_title(tab)

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

return config
