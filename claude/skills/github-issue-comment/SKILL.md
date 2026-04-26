---
name: github-issue-comment
description: git push 後に、ブランチ名から関連する GitHub Issue を特定してコメントを追加する。push したが作業が完了していない場合に使用する。
user-invocable: true
allowed-tools: Bash
---

# GitHub Issue コメントスキル

`git push` を実行した後、作業が完了していない場合に関連 Issue へ進捗コメントを追加する。

## Issue 番号の特定

ブランチ名から Issue 番号を抽出する：

```bash
git branch --show-current
```

ブランチ名の命名規則: `<type>/issue-<番号>-<説明>`
例: `feat/issue-26-claude-skills` → Issue #26

## 手順

1. 現在のブランチ名を取得し、`issue-{番号}` の部分から Issue 番号を特定する
2. 直近の push 内容（コミットメッセージ・変更ファイル）を確認する：
   ```bash
   git log -1 --pretty=format:"%s" 
   git diff HEAD~1 --name-only
   ```
3. 以下の形式でコメントを作成する：
   ```bash
   gh issue comment <番号> --body "$(cat <<'EOF'
   ## 作業ログ

   ### 実施内容
   - 

   ### 変更ファイル
   - 

   ### 次のステップ
   - 
   EOF
   )"
   ```

## 注意事項

- ブランチ名に `issue-{番号}` が含まれない場合はユーザーに Issue 番号を確認する
- コメントは簡潔に。変更の「何をしたか」と「次に何をするか」を明記する
- 作業が完了した場合はこのスキルを使わず、`github-pr` スキルで PR を作成してクローズする
