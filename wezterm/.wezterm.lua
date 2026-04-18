local home = os.getenv("HOME")
package.path = package.path .. ";" .. home .. "/.dotfiles/?.lua"
local wezterm = require 'wezterm'
local config = {}
local p = require("theme.palette")
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- 見た目の設定
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
local ansi = {
  p.base01,
  p.base08,
  p.base0B,
  p.base0A,
  p.base0D,
  p.base0E,
  p.base0C,
  p.base05,
}

local brights = {
  p.base03,
  p.base08,
  p.base0B,
  p.base0A,
  p.base0D,
  p.base0E,
  p.base0C,
  p.base07,
}
config.colors = {
  foreground = p.base05,
  background = p.base00,
  cursor_bg = p.base05,
  cursor_fg = p.base00,
  cursor_border = p.base05,
  selection_bg = p.base02,
  selection_fg = p.base07,

  ansi = ansi,
  brights = brights,

  -- タブバーの色をパレットに合わせる
  tab_bar = {
    background = p.base00,
    active_tab = {
      bg_color = p.base02,
      fg_color = p.base07,
    },
    inactive_tab = {
      bg_color = p.base01,
      fg_color = p.base04,
    },
    inactive_tab_hover = {
      bg_color = p.base02,
      fg_color = p.base05,
    },
    new_tab = {
      bg_color = p.base01,
      fg_color = p.base04,
    },
    new_tab_hover = {
      bg_color = p.base02,
      fg_color = p.base05,
    },
  },
}


-- ウィンドウの初期サイズ設定
config.initial_cols = 220
config.initial_rows = 50

-- タブバーの設定
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false

-- フォント関係の設定
config.font = wezterm.font_with_fallback({
  { family = "IBM Plex Mono", weight = "Medium" },
  "HackGenConsoleNF",  -- 日本語 + Nerd Font アイコン
})
config.font_size = 13

-- 横幅の調整
config.cell_width = 0.90
-- 行間の調整
config.line_height = 0.95

-- スクロールバック行数
config.scrollback_lines = 10000

-- IME の確定前の文字列を表示する
config.use_ime = true

-- キーバインドを明示的に再設定
config.keys = {
  -- Cmd + Shift + P (コマンドパレット)
  { key = "P", mods = "SHIFT|CMD", action = wezterm.action.ActivateCommandPalette },
  -- Cmd + R (設定リロード)
  { key = "r", mods = "CMD", action = wezterm.action.ReloadConfiguration },
  -- Cmd + D: ペインを縦に分割（左右）
  { key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({domain="CurrentPaneDomain"}) },
  -- Cmd + Shift + D: ペインを横に分割（上下）
  { key = "D", mods = "SHIFT|CMD", action = wezterm.action.SplitVertical({domain="CurrentPaneDomain"}) },
  -- Cmd + [Arrow Key]: ペインの移動
  { key = "LeftArrow", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Down") },
  -- Cmd + W: アクティブなペインを閉じる
  { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({confirm=true}) },
  -- Cmd + T: 新しいタブを開く
  { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  -- Cmd + Shift + [ / ]: タブの前後切り替え
  { key = "{", mods = "SHIFT|CMD", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "}", mods = "SHIFT|CMD", action = wezterm.action.ActivateTabRelative(1) },
  -- Cmd + 1〜9: タブの直接切り替え
  { key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "CMD", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "CMD", action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "CMD", action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "CMD", action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "CMD", action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "CMD", action = wezterm.action.ActivateTab(8) },
  -- Cmd + +/-: フォントサイズの変更
  { key = "+", mods = "CMD", action = wezterm.action.IncreaseFontSize },
  { key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize },
  { key = "0", mods = "CMD", action = wezterm.action.ResetFontSize },
  -- Cmd + Enter: 全画面化する
  { key = "Enter", mods = "CMD", action = wezterm.action.ToggleFullScreen }
}

return config
