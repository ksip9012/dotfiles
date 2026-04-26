---
name: github-issue-create
description: GitHub Issue をテンプレートを使って作成する。Issue 作成を依頼されたときに使用する。
user-invocable: true
allowed-tools: Bash, Read, Glob
---

# GitHub Issue 作成スキル

GitHub Issue をプロジェクトのテンプレートに基づいて作成する。

## ラベル一覧

| ラベル | 用途 |
|---|---|
| `feat` | 新機能・機能追加 |
| `fix` | バグ修正 |
| `docs` | ドキュメント |
| `chore` | 保守・依存関係更新などの雑務 |
| `refactor` | リファクタリング |
| `ci` | CI/CD 関連 |
| `idea` | アイデア・提案 |
| `research` | 技術調査・検証 |

## テンプレート選択ルール

内容に応じて以下のテンプレートを選択する：

- **bug_report**: エラー・不具合の報告
- **feature**: 開発タスク・機能追加・改善（デフォルト）
- **research**: 技術調査・検証

## 手順

1. ユーザーの依頼内容からテンプレートとラベルを判断する
2. プロジェクトの `.github/ISSUE_TEMPLATE/` にテンプレートが存在するか確認する
3. テンプレートの内容をユーザーの依頼内容で埋める
4. 以下のコマンドで Issue を作成する：

```bash
gh issue create \
  --title "タイトル" \
  --label "ラベル" \
  --assignee "ksip9012" \
  --body "$(cat <<'EOF'
テンプレートの本文
EOF
)"
```

5. 作成された Issue の URL をユーザーに伝える

## 注意事項

- assignees は常に `ksip9012` を設定する
- ラベルが存在しない場合は作成してから Issue を作成する：
  ```bash
  gh label create "ラベル名" --color "カラーコード" --description "説明"
  ```
- タイトルはテンプレートの `title` プレフィックスに従う（例：`[fix] `, `[research] `）

## ラベルのカラーコード

| ラベル | カラー |
|---|---|
| `feat` | `#0075ca` |
| `fix` | `#d73a4a` |
| `docs` | `#0075ca` |
| `chore` | `#e4e669` |
| `refactor` | `#a2eeef` |
| `ci` | `#f9d0c4` |
| `idea` | `#d876e3` |
| `research` | `#fbca04` |
