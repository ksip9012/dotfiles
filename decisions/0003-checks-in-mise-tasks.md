# 0003. チェックは mise のタスクに書き、GitHub Actions は薄くする

- Status: Accepted
- Date: 2026-11-03

## Context
CI に GitHub Actions を使うかを決める必要があった。GitHub Actions の YAML は GitHub でしか動かない。一方で、Issue・PR・Dependabot・スキルなど、すでに GitHub に乗っているので、CI だけ外しても GitHub への依存はあまり減らない。

また、手元・pre-commit・CI で、版やコマンドがそれぞれ違っていた（CI のひな形は setup-python で Python 3.12、手元は mise で 3.13 など）。

## Decision
GitHub Actions は使う。ただし、lint・format・型チェック・テストの中身は、リポジトリの `mise.toml` の `[tasks.check]` に書き、手元・pre-commit・CI で同じ `mise run check` を動かす。CI の YAML は「チェックアウト → `jdx/mise-action` で mise の版をそろえる → `mise run check`」だけにする。

## Consequences
- 手元・pre-commit・CI で、同じ版の同じチェックになる。言語の版は `mise.toml` の 1か所で決まる
- ほかの CI に移るときは、YAML の数行を書き直すだけで済む
- CI が動くには、中身がリポジトリにそろっている必要がある: タスクと版はリポジトリの `mise.toml` に書く（グローバルの設定や `mise.local.toml` には書かない）、依存は lock ファイルでコミットする、チェックに秘密の値を使わない
- mise は信頼していない設定ファイルを読まないので、CI では `MISE_TRUSTED_CONFIG_PATHS` で信頼させる。新しい PC では最初に `mise trust` が要る
- pre-commit が入っていない PC（会社の PC やブラウザの Claude Code など）から push しても、CI が同じチェックを動かす
