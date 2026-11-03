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
| `gh/config.yml` | `~/.config/gh/config.yml` |
| `homebrew/curlrc` | `~/.config/homebrew/curlrc`（`HOMEBREW_CURLRC` は `03_env.zsh` で設定） |

`claude/rules/` は `~/.claude/rules` にリンクする（GitHub の運用と、言語ごとのコードの書き方）。

### 開発のひな形と決めごと

- `templates/`: 新しいプロジェクトに置く土台（共通 `common/` と言語ごと `python/`）。リンクはしない。使い方は `templates/README.md`
- `rules/<言語>.md` はコードの書き方だけにし、開発環境の設定は `templates/` のひな形に置く。環境を変えるときはひな形を直す（`decisions/0002`）
- `decisions/`: dotfiles の設計の決めごと（ADR）。大きな決めごとをしたら、`decisions/0000-template.md` を写して足す

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
