# Global Claude Code Rules

- 回答はすべて**日本語**で行う。
- 環境: macOS、Shell は zsh。
- dotfiles は `~/.dotfiles/` で XDG Base Directory Specification に準拠して管理している。

## GitHub 運用ルール

### ブランチ戦略

GitHub Flow を採用。常に `main` からブランチを切り、PR 経由でマージする。

### ブランチ作成

**Issue への取り組みを開始する前に、必ず `github-branch` スキルでブランチを作成する。**

命名規則: `<type>/issue-<番号>-<簡潔な説明>`
例: `feat/issue-32-github-branch-skill`

type は `feat` / `fix` / `docs` / `chore` / `refactor` / `ci` / `idea` / `research` から選ぶ。

### Issue 作成

**Issue 作成時は必ず以下を設定する：**
- `--assignee ksip9012`
- `--label <内容に対応するラベル>`

### git push 後のコメント

`git push` を実行した後、その Issue の作業が**完了していない**場合は必ず `github-issue-comment` スキルを呼び出してコメントを追記する。作業が完了した場合は `github-pr` スキルで PR を作成する。

### PR 作成

**PR 作成時は必ず以下を設定する：**
- `--assignee ksip9012`
- `--label <type に対応するラベル>`
- 本文に `Closes #<Issue 番号>` を含める
