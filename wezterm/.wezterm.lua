local wezterm = require 'wezterm'
local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- 見た目の設定
config.color_scheme = 'Astrodark (Goth)'
config.window_background_opacity = 0.85
config.window_decorations = "RESIZE"
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }

-- ウィンドウの初期サイズ設定
config.initial_cols = 80
config.initial_rows = 20

-- タブバーの設定
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
wezterm.on("update-right-status", function(window, pane)
  window:set_right_status(wezterm.format({
    { Foreground = { AnsiColor = "Aqua" }},
    { Text = wezterm.strftime("%Y-%m-%d %H:%M ")}
  }))
end)

-- フォント関係の設定
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 14
config.harfbuzz_features = { "liga=1", "calt=1" }

-- IME の確定前の文字列を表示する
config.use_ime = true

-- キーバインドを明示的に再設定
config.keys = {
  -- Cmd + Shift + P (コマンドパレット)
  { key = "P", mods = "SHIFT|CMD", action = wezterm.action.ActivateCommandPalette },
  -- Cmd + R (設定リロード)
  { key = "r", mods = "CMD", action = wezterm.action.ReloadConfiguration },
  -- Cmd + Shift + R (設定リロードの別定義、デフォルトは CTRL+SHIFT+R)
  { key = "R", mods = "SHIFT|CMD", action = wezterm.action.ReloadConfiguration },
  -- Cmd + D: ペインを縦に分割（左右）
  { key = "d", mods = "CMD", action = wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}} },
  -- Cmd + Shift + D: ペインを横に分割（上下）
  { key = "D", mods = "SHIFT|CMD", action = wezterm.action{SplitVertical={domain="CurrentPaneDomain"}} },
  -- Cmd + [Arrow Key]: ペインの移動
  { key = "LeftArrow", mods = "CMD", action = wezterm.action{ActivatePaneDirection="Left"} },
  { key = "RightArrow", mods = "CMD", action = wezterm.action{ActivatePaneDirection="Right"} },
  { key = "UpArrow", mods = "CMD", action = wezterm.action{ActivatePaneDirection="Up"} },
  { key = "DownArrow", mods = "CMD", action = wezterm.action{ActivatePaneDirection="Down"} },
  -- Cmd + W: アクティブなペインを閉じる
  { key = "w", mods = "CMD", action = wezterm.action{CloseCurrentPane={confirm=true}} },
  -- Cmd + T: 新しいタブを開く
  { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  -- Cmd + Shift + [ / ]: タブの切り替え
  { key = "{", mods = "SHIFT|CMD", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "}", mods = "SHIFT|CMD", action = wezterm.action.ActivateTabRelative(1) },
  -- Cmd + +/-: フォントサイズの変更
  { key = "+", mods = "CMD", action = wezterm.action.IncreaseFontSize },
  { key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize },
  { key = "0", mods = "CMD", action = wezterm.action.ResetFontSize }
}

return config
