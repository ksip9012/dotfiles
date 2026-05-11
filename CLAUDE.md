# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## セットアップ

```bash
./install.sh
```

ホームディレクトリへのシンボリックリンク作成と Homebrew パッケージのインストールを一括実行する。

## Homebrew 管理

`Brewfile` は手動編集せず、`mbrew` エイリアスで一括メンテナンス後に自動更新する（`brew bundle dump --force`）。

## アーキテクチャ

### シンボリックリンク構造

`install.sh` が各設定ファイルを `~/.dotfiles/` から適切な場所へリンクする。主なリンク先：

| dotfiles パス | リンク先 |
|---|---|
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zsh.d/` | `~/.zsh.d/` |
| `nvim/` | `~/.config/nvim/` |
| `starship/.starship.toml` | `~/.config/starship.toml` |
| `sheldon/` | `~/.config/sheldon/` |
| `mise/` | `~/.config/mise/` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |

`claude/github/` と `claude/python/` は `~/.claude/` へのリンク不要。各プロジェクトの CLAUDE.md から `@~/.dotfiles/claude/<dir>/CLAUDE.md` で参照する。

### zsh 設定の分割構造

`.zshrc` は `zsh/.zsh.d/` 内の `*.zsh` ファイルをファイル名の番号順に読み込む。新しい設定ファイルは番号プレフィックスで順序を管理する。sheldon は遅延読み込み（`zsh-defer`）を使用。

### Neovim 設定

- プラグイン管理: `lazy.nvim`（`nvim/lua/plugins.lua`）
- LSP: Neovim 0.10+ ビルトイン `vim.lsp.config` / `vim.lsp.enable` を使用（`nvim/lua/lsp/init.lua`）
- LSP サーバーのインストール管理: Mason（`nvim/lua/plugins.lua`）
- 有効な LSP: Ruff（Python、`lineLength = 79`）、LuaLS（Lua）
- 補完: `nvim-cmp` + `cmp-nvim-lsp`
- `nvim/lazy-lock.json` は `.gitignore` で除外（常に最新プラグインを使う方針）

### ランタイム管理

`mise` で Python・Node.js・Poetry バージョンを管理（`mise/config.toml`）。プロジェクト固有バージョンは `mise.toml` をプロジェクトルートに配置する。
