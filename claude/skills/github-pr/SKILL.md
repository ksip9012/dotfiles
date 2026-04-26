---
name: github-pr
description: 作業完了後に PR を作成し、関連 Issue をクローズする。assignees・labels を自動設定する。
user-invocable: true
allowed-tools: Bash, Read
---

# PR 作成スキル

作業が完了したら呼び出す。ブランチ情報と Issue 情報をもとに PR を作成する。

## 手順

### 1. ブランチ・Issue 情報の取得

```bash
# 現在のブランチ名を取得
git branch --show-current

# ブランチ名から Issue 番号を抽出（例: feat/issue-34-github-pr-skill → 34）
# Issue 情報を取得
gh issue view <番号> --json title,labels
```

### 2. リモートへの push 確認

未 push のコミットがあれば push する：

```bash
git push -u origin <branch-name>
```

### 3. コミット履歴の確認

PR の説明生成に使用する：

```bash
git log main..<branch-name> --pretty=format:"%s"
git diff main --name-only
```

### 4. PR の作成

`~/.dotfiles/github/pull_request_template.md` を参考に本文を生成し、以下のコマンドで PR を作成する：

```bash
gh pr create \
  --title "<type>: <Issue タイトルを簡潔に>" \
  --base main \
  --assignee "ksip9012" \
  --label "<Issue のラベルと同じ>" \
  --body "$(cat <<'EOF'
## Summary

- <変更内容を箇条書き>

## Related Issue

Closes #<番号>

## Test plan

- [ ] <確認事項>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### 5. 完了報告

作成した PR の URL をユーザーに伝える。

## 注意事項

- `--assignee` は常に `ksip9012` を設定する
- `--label` は Issue に設定されているラベルと同じものを使う。ラベルがリポジトリに存在しない場合は先に作成する：
  ```bash
  gh label create "<ラベル名>" --color "<カラーコード>"
  ```
- PR タイトルは `<type>: <説明>` の形式にする（例: `feat: github-pr スキルを追加する`）
- `Closes #<番号>` を本文に含めることで、PR マージ時に Issue が自動クローズされる
- レビュー依頼（`--reviewer`）は設定しない
