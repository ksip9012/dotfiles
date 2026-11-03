# 0002. claude/rules/<言語>.md はコードの書き方だけにし、環境の設定はひな形に置く

- Status: Accepted
- Date: 2026-11-03

## Context
`claude/rules/python.md` に、コードの書き方（PEP 8・型ヒント・例外・テスト）と、開発環境の設定例（src レイアウト、mise + uv、ruff・pyright・pre-commit）が 1つに入っていた。設定例と、github-init の CI のひな形（Python 3.12・pip）が食い違っていた。ルールは Claude が `.py` を触るたびに読む。

## Decision
`rules/<言語>.md` はコードの書き方だけにする。環境の設定は、ひな形（`templates/`）に実物のファイルとして置き、ルールには「環境はひな形のとおり」とだけ書く。ほかの言語のルールも同じ分け方にする。

## Consequences
- 設定例と実物がずれなくなる。設定を変えるときは、ひな形だけを直す
- Claude が毎回読む量が減る
- 環境の説明（コマンドの例など）は、`templates/README.md` に置く
- 選ばなかった案: 1つのままにする（2か所を直すことになる）、環境の説明だけ別のルールファイルにする（ひな形とは別に説明が残り、やはりずれうる）
