local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" })
config.font_size = 14.0

-- Monokai Pro color scheme
config.color_scheme = "Monokai Pro (Gogh)"

-- Window
config.window_decorations = "RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

-- Cursor
config.default_cursor_style = "SteadyBar"

-- Performance (Apple Silicon)
config.front_end = "WebGpu"

-- Terminal
config.term = "xterm-256color"

-- Keybinds for tmux-friendly usage
config.keys = {
  -- Cmd+d for vertical split (sends tmux prefix + |)
  { key = "d", mods = "CMD", action = wezterm.action.SendString("\x01|") },
  -- Cmd+shift+d for horizontal split (sends tmux prefix + -)
  { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SendString("\x01-") },
  -- Cmd+t for new tmux window
  { key = "t", mods = "CMD", action = wezterm.action.SendString("\x01c") },
  -- Cmd+w to close tmux pane
  { key = "w", mods = "CMD", action = wezterm.action.SendString("\x01x") },
}

return config
