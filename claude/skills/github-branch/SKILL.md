---
name: github-branch
description: Issue に取り組む際に GitHub Flow に基づいてブランチを作成する。Issue 番号からブランチ名を自動生成し、main を最新化してからブランチを切る。
user-invocable: true
allowed-tools: Bash
---

# ブランチ作成スキル

Issue への取り組みを開始するときに呼び出す。GitHub Flow に基づき、常に `main` から作業ブランチを切る。

## ブランチ命名規則

```
<type>/issue-<番号>-<簡潔な説明>
```

例: `feat/issue-32-github-branch-skill`

### type 一覧

| type | 用途 |
|---|---|
| `feat` | 新機能・機能追加 |
| `fix` | バグ修正 |
| `docs` | ドキュメント |
| `chore` | 保守・依存関係更新などの雑務 |
| `refactor` | リファクタリング |
| `ci` | CI/CD 関連 |
| `idea` | アイデア・提案 |
| `research` | 技術調査・検証 |

## 手順

### 1. Issue 情報の取得

Issue 番号が指定されている場合はそこから取得する：

```bash
gh issue view <番号> --json title,labels
```

指定がない場合はユーザーに Issue 番号を確認する。

### 2. type の判定

Issue のラベルから type を決定する。ラベルが未設定の場合は Issue タイトル・内容から判断する。

### 3. ブランチ名の生成

- Issue タイトルをもとに簡潔な英語スラッグを生成（スペース→ハイフン、小文字）
- 最終的なブランチ名をユーザーに提示して確認を取る

### 4. ブランチの作成

```bash
git checkout main
git pull origin main
git checkout -b <branch-name>
```

### 5. 完了報告

作成したブランチ名をユーザーに伝える。

## 注意事項

- リモートへの push はこのスキルでは行わない（作業後の最初の push に委ねる）
- 未コミットの変更がある場合は事前に `git stash` するか、ユーザーに確認する
- ブランチ名の説明部分は短く（3〜5単語程度）、内容が伝わるものにする
