# dotfiles

macOS 向けの個人設定ファイル管理リポジトリ。  
[XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/) に準拠して管理している。

## 動作環境

- macOS
- Shell: zsh
- Neovim >= 0.10

## セットアップ

### 1. Homebrew のインストール

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/homebrew/install/HEAD/install.sh)"
```

### 2. dotfiles のクローンとセットアップ

```bash
git clone https://github.com/ksip9012/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` は以下を一括実行する。

- Homebrew パッケージのインストール（`Brewfile` が変更されている場合のみ）
- カラーパレットファイルの生成（`theme/palette.lua` → starship・eza）
- git ユーザー情報のセットアップ（`~/.config/git/local` が未作成の場合のみ対話入力）
- シンボリックリンクの作成と検証

## 管理している設定

### シェル・プロンプト

| ツール | 用途 |
|---|---|
| zsh | シェル設定・補完・履歴 |
| [sheldon](https://sheldon.cli.rs/) | zsh プラグイン管理（`zsh-defer` で遅延ロード） |
| [starship](https://starship.rs/) | プロンプト（バイナリ mtime キャッシュで高速起動） |
| [mise](https://mise.jdx.dev/) | ランタイムバージョン管理（Python・Node.js）（キャッシュで高速起動） |

### エディタ・ターミナル

| ツール | 用途 |
|---|---|
| [Neovim](https://neovim.io/) | エディタ（lazy.nvim / LSP / conform.nvim） |
| [WezTerm](https://wezfurlong.org/wezterm/) | ターミナル（`~/.config/wezterm/wezterm.lua`） |

### モダン CLI ツール（エイリアス設定済み）

| コマンド | ツール | 代替対象 |
|---|---|---|
| `cat` | [bat](https://github.com/sharkdp/bat) | `cat` |
| `ls` / `ll` / `lt` | [eza](https://eza.rocks/) | `ls` |
| `cd` / `cdi` | [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` |
| `du` | [dust](https://github.com/bootandy/dust) | `du` |
| `ps` | [procs](https://github.com/dalance/procs) | `ps` |
| `top` | [bottom](https://github.com/ClementTsang/bottom) | `top` |
| `rm` | [rip](https://github.com/nivekuil/rip) | `rm`（ゴミ箱送りで復元可能） |
| `git diff` | [delta](https://github.com/dandavison/delta) | git pager |

その他インストール済み: `fd` / `fzf` / `xh` / `sd` / `hyperfine`

### その他

| ツール | 用途 |
|---|---|
| git | グローバル設定（delta pager・エイリアス） |
| [Claude Code](https://claude.ai/code) | 設定・スキル・CLAUDE.md |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | 設定 |
| VS Code | キーバインド・設定 |
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | タイルウィンドウマネージャ |
| [Raycast](https://www.raycast.com/) | ランチャー |
| [newsboat](https://newsboat.org/) | RSS リーダー |

## アーキテクチャ

### シンボリックリンク構造

| dotfiles パス | リンク先 |
|---|---|
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zsh.d/` | `~/.zsh.d/` |
| `nvim/` | `~/.config/nvim/` |
| `starship/.starship.toml` | `~/.config/starship.toml` |
| `sheldon/` | `~/.config/sheldon/` |
| `mise/` | `~/.config/mise/` |
| `wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` |
| `git/.config/git/config` | `~/.config/git/config` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |

### zsh 設定の分割構造

`.zshrc` は `zsh/.zsh.d/` 内の `*.zsh` をファイル名の番号順に読み込む。

| ファイル | 内容 |
|---|---|
| `00_path.zsh` | PATH・XDG 変数定義 |
| `01_command_input.zsh` | 履歴・補完オプション |
| `02_alias.zsh` | エイリアス・関数定義 |
| `03_env.zsh` | 環境変数 |
| `04_fzf.zsh` | fzf 設定（ripgrep 連携） |
| `05_zoxide.zsh` | zoxide 初期化 |
| `06_eza.zsh` | LS_COLORS（パレットから自動生成） |

`mise` と `starship` の初期化はバイナリの更新日時をキーにキャッシュし、毎回のサブプロセス起動を省略している（`~/.cache/zsh/` に保存）。

### Neovim 設定

- プラグイン管理: `lazy.nvim`（`nvim/lua/plugins.lua`）
- LSP: Neovim 0.10+ ビルトイン `vim.lsp.config` / `vim.lsp.enable`（`nvim/lua/lsp/init.lua`）
- LSP サーバー: Ruff（Python lint/format）・Pyright（Python 型チェック）・LuaLS（Lua）
- フォーマッタ: `conform.nvim`（保存時自動フォーマット）

| 言語 | フォーマッタ |
|---|---|
| Python | Ruff（LSP 経由） |
| Lua | stylua |
| Markdown / JS / TS / JSON / YAML / HTML / CSS | prettier |

### カラーパレット

`theme/palette.lua` が唯一の定義元（base16 形式）。色を変更した場合は以下を実行する。

```bash
python3 theme/generate.py
```

以下のファイルが自動生成される。

| 生成ファイル | 用途 |
|---|---|
| `starship/.starship.toml` の `[palettes.custom]` | starship プロンプト |
| `zsh/.zsh.d/06_eza.zsh` | eza / ls の色（hex → ANSI RGB 変換） |
| `theme/palette.toml` | 参考用 |

### Homebrew 管理

`Brewfile` は手動編集せず、`mbrew` エイリアスで一括メンテナンス後に自動更新する（`brew bundle dump --force`）。

## CI

GitHub Actions で PR・main push 時に以下を自動検証する。

| ジョブ | 内容 |
|---|---|
| shellcheck | `install.sh` のシェルスクリプト検証 |
| luacheck | `nvim/lua/` の Lua 構文チェック |
| Brewfile syntax | `ruby -c Brewfile` で構文検証 |

## トラブルシューティング

**シンボリックリンクが壊れている**

```bash
./install.sh  # verify セクションで ❌ が表示される
```

**mise / starship が正常に動かない**

キャッシュを削除して再生成する。

```bash
rm ~/.cache/zsh/mise_init.zsh ~/.cache/zsh/starship_init.zsh
zsh  # 次回起動時に自動再生成
```

**Brewfile のハッシュキャッシュをリセットしたい**

```bash
rm ~/.cache/dotfiles/brewfile.sha256
./install.sh
```

## 言語別メモ

### python

- 型チェッカーには `pyright` を利用
- `ty` が 1.0 になったら置き換えを考える
