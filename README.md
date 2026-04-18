# dotfiles

macOS 向けの個人設定ファイル管理リポジトリ。  
[XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/) に準拠して管理している。

## 動作環境

- macOS
- Shell: zsh

## 管理している設定

| ツール | 用途 |
|---|---|
| zsh | シェル設定・補完・履歴 |
| [sheldon](https://sheldon.cli.rs/) | zsh プラグイン管理 |
| [starship](https://starship.rs/) | プロンプト |
| [WezTerm](https://wezfurlong.org/wezterm/) | ターミナルエミュレータ |
| [Neovim](https://neovim.io/) | エディタ（lazy.nvim / LSP） |
| [mise](https://mise.jdx.dev/) | ランタイムバージョン管理（Python・Node.js） |
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | タイルウィンドウマネージャ |
| [Raycast](https://www.raycast.com/) | ランチャー |
| [newsboat](https://newsboat.org/) | RSSリーダー |
| [Claude Code](https://claude.ai/code) | AI コーディングアシスタント設定 |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | AI コーディングアシスタント設定 |
| VS Code | キーバインド・設定 |
| git | グローバル設定（`core`・`init` のみ） |

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

`install.sh` はシンボリックリンクの作成と Homebrew パッケージのインストールを一括実行する。

### 3. 手動セットアップ

#### git ユーザー情報

git のユーザー情報（名前・メールアドレス）はリポジトリ管理外のため、各マシンで手動作成する。

```bash
# ~/.config/git/local
[user]
    name = Your Name
    email = your@email.com
```
