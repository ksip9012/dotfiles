# 0001. 開発のひな形は dotfiles の templates/ にまとめる

- Status: Accepted
- Date: 2026-11-03

## Context
新しいプロジェクトの土台（`mise.toml`・pre-commit・CI・`.gitignore`・ADR のテンプレートなど）は、リポジトリごとに手で作っていて形がばらばらだった。ひな形に近いものは 3か所に分かれていた。

- Issue・PR テンプレート: dotfiles の `github/`
- Claude のルール（`python.md` など）: dotfiles の `claude/rules/`
- CI のひな形: agent-skills の github-init スキルの中（`ci/`）

## Decision
ひな形は dotfiles の `templates/` に、共通の部分（`common/`）と言語ごとの部分（`python/` など）に分けてまとめる。github-init スキルは、それを読んで置くだけの手順にする。

## Consequences
- ひな形とルールが dotfiles にそろい、1か所を見ればよくなる
- ひな形はただのファイルなので、Claude 以外（Antigravity・Codex・自分のスクリプト）からも使える。正は plain text に置き、道具はその上の薄い層にする
- github-init の `ci/` は使わなくなるので、github-init を直すときに消す
- 選ばなかった案: github-init の中に置く（ひな形がスキルの形式に寄りかかる）、言語ごとの GitHub のテンプレートリポジトリ（リポジトリが増え、共通の部分を直すときに全部を直す）
