# 0005. dependabot.yml では GitHub Actions の版だけを月 1回上げる

- Status: Accepted
- Date: 2026-11-03

## Context
CI の YAML の Actions（`actions/checkout`・`jdx/mise-action` など）の版は、古くなるといずれ動かなくなったり、セキュリティの問題が出たりする。言語の依存のセキュリティの修正は、リポジトリの設定の Dependabot security updates（全リポジトリでオン）で、`dependabot.yml` がなくても PR が来る。

## Decision
共通のひな形に `.github/dependabot.yml` を入れ、`github-actions` だけを月 1回上げる。言語の依存（uv・go mod など）の版の更新は入れない。

## Consequences
- Actions の版が自動で新しくなる。PR は月 1回くらい
- 言語の依存は、セキュリティの問題があるものだけ自動で直る。問題がない版の更新は、自分で必要なときに上げる
- 言語の依存の更新も入れる案は、問題がなくても上げる PR が増えるので選ばなかった
