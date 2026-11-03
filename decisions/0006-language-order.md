# 0006. 言語ごとのひな形は Python → Go の順に作る

- Status: Accepted
- Date: 2026-11-03

## Context
言語ごとのひな形をどの言語から作るかを決める必要があった。手元のリポジトリには Python・Go・Rust・Node がある。

## Decision
Python → Go の順に作る。Rust と Node は、使う予定ができてから作る。

## Consequences
- Python はいちばん使っていて、`rules/python.md` とひな形のずれを直すところから始められる
- Go は、試作のリポジトリにある pre-commit（gofmt・go vet・go test）と、`mise.toml` の `[env]` で GOPATH などをプロジェクトの中に閉じ込める形を、ひな形にする
- 毎日使う言語から作るので、作ったひな形をすぐ使える
