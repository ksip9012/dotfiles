---
name: github-init
description: 新規プロジェクトの GitHub 環境を初期化する。git init や gh repo create の直後に呼び出す。Issue テンプレート・PR テンプレートの生成とラベルのセットアップを行う。
user-invocable: true
allowed-tools: Bash, Read, Glob, Write
---

# GitHub 環境初期化スキル

新規プロジェクトで `/github-init` を呼び出すと、プロジェクトの種別を自動判定してテンプレートとラベルをセットアップする。

## 手順

### 1. プロジェクト種別の判定

以下のファイルを確認してプロジェクト種別を判定する：

```bash
ls -1
```

| ファイル | 判定 |
|---|---|
| `requirements.txt` / `pyproject.toml` / `setup.py` | Python |
| `package.json` | Node.js / JavaScript / TypeScript |
| `Brewfile` / `.zshrc` / `*.zsh` | dotfiles / shell |
| `Dockerfile` / `docker-compose.yml` | Docker |
| `go.mod` | Go |
| 上記なし | 汎用 |

複数該当する場合は最も主要なものを選ぶ。判定結果をユーザーに確認してから次に進む。

### 2. Issue テンプレートの生成

ベーステンプレートを `~/.dotfiles/github/ISSUE_TEMPLATE/` から読み込み、プロジェクト種別に応じて調整する。

#### 種別ごとの調整内容

**Python:**
- `bug_report.md` の環境欄に以下を追加：
  ```
  - Python Version: [e.g. 3.12]
  - 仮想環境: [venv / poetry / conda]
  ```

**Node.js / JavaScript:**
- `bug_report.md` の環境欄に以下を追加：
  ```
  - Node Version: [e.g. 20.x]
  - パッケージマネージャー: [npm / yarn / pnpm]
  ```

**dotfiles / shell:**
- `bug_report.md` の環境欄に以下を追加：
  ```
  - Shell: [zsh / bash]
  - macOS Version:
  ```
- `research.md` の調査ログ欄に「検証コマンド」欄を追加

**Docker:**
- `bug_report.md` の環境欄に以下を追加：
  ```
  - Docker Version:
  - docker-compose Version:
  ```

**汎用:** ベーステンプレートをそのまま使用

生成先：
```bash
mkdir -p .github/ISSUE_TEMPLATE
# 調整済みテンプレートを書き込む
```

### 3. PR テンプレートの生成

`~/.dotfiles/github/pull_request_template.md` を `.github/pull_request_template.md` にコピーする：

```bash
cp ~/.dotfiles/github/pull_request_template.md .github/pull_request_template.md
```

### 4. ラベルのセットアップ

既存のデフォルトラベルを削除してから、カスタムラベルを作成する：

```bash
# デフォルトラベルの削除
gh label list --json name | jq -r '.[].name' | xargs -I {} gh label delete "{}" --yes

# カスタムラベルの作成
gh label create "feat"     --color "#0075ca" --description "新機能・機能追加"
gh label create "fix"      --color "#d73a4a" --description "バグ修正"
gh label create "docs"     --color "#0052cc" --description "ドキュメント"
gh label create "chore"    --color "#e4e669" --description "保守・依存関係更新などの雑務"
gh label create "refactor" --color "#a2eeef" --description "リファクタリング"
gh label create "ci"       --color "#f9d0c4" --description "CI/CD 関連"
gh label create "idea"     --color "#d876e3" --description "アイデア・提案"
gh label create "research" --color "#fbca04" --description "技術調査・検証"
```

### 5. 完了報告

以下の内容をユーザーに伝える：
- 判定したプロジェクト種別
- 生成したファイル一覧
- セットアップしたラベル一覧

## 注意事項

- `.github/` ディレクトリはプロジェクトにコピー（シンボリックリンクではない）
- GitHub リポジトリがまだ作成されていない場合、ラベルのセットアップはスキップしてファイル生成のみ行う
- `gh label delete` が失敗する場合（権限不足など）はスキップして先に進む
