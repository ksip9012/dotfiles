# 開発のひな形

新しいプロジェクトに置く土台のファイル。共通の部分（`common/`）と、言語ごとの部分（`python/`・`go/`・`rust/`）に分けてある。決めた理由は `../decisions/` の ADR。

## 構成

```
templates/
├── common/                      # どの言語でも置く
│   ├── .github/
│   │   ├── workflows/ci.yml     # チェックアウト → mise で版をそろえる → mise run check
│   │   └── dependabot.yml       # GitHub Actions の版だけを月 1回上げる
│   ├── .gitignore               # OS・手元だけの設定・秘密の値
│   ├── .pre-commit-config.yaml  # コミットの前に mise run check
│   └── decisions/0000-template.md
├── python/                      # Python のプロジェクトに足す
│   ├── .gitignore               # Python の部分（common の .gitignore に足す）
│   ├── mise.toml                # [tools] の版と [tasks] の check・fix・upgrade
│   ├── pyproject.toml           # ruff・pyright・pytest の設定と、開発用の依存
│   ├── src/package_name/__init__.py
│   └── tests/test_import.py
└── go/                          # Go のプロジェクトに足す
    ├── .gitignore               # Go の部分（common の .gitignore に足す）
    ├── mise.toml                # [tools] の版（go・pre-commit）、[env] の .go/、[tasks] の check・fix・upgrade
    ├── go.mod
    ├── modulename.go
    └── modulename_test.go
└── rust/                        # Rust のプロジェクトに足す
    ├── .gitignore               # Rust の部分（common の .gitignore に足す）
    ├── mise.toml                # [tools] の版（rust・pre-commit）、[tasks] の check・fix・upgrade
    ├── Cargo.toml
    └── src/lib.rs
```

- チェックの中身（lint・format・型チェック・テスト）は、言語ごとの `mise.toml` の `[tasks.check]` に書く。CI と pre-commit は `mise run check` を呼ぶだけなので、言語によらず共通にできる
- Issue・PR テンプレートは `../github/` にある（github-init が置く）

## 使い方（Python の例）

```bash
cd <新しいプロジェクト>
cp -R ~/.dotfiles/templates/common/. .
cp -R ~/.dotfiles/templates/python/. .
cat ~/.dotfiles/templates/common/.gitignore ~/.dotfiles/templates/python/.gitignore > .gitignore

# package-name / package_name を、プロジェクトの名前に置き換える
#   pyproject.toml の name、src/package_name/、tests/test_import.py の import

mise trust            # この mise.toml を信頼する（新しい PC でも最初に 1回）
uv sync               # 依存を入れる（.venv を作る）
uv run pre-commit install
mise run check        # lint・format・型チェック・速いテスト
```

- CI を置くかの線引き: `personal-products/` は必須、`playground/` は任意（`../decisions/0004`）。置かないときは `.github/workflows/` を消す
- 依存は `uv add <パッケージ>`（開発用は `uv add --dev`）。`pyproject.toml` には下限だけ（`uv add` が書く `>=` の形）を書き、固定は `uv.lock` に任せる。`uv.lock` はコミットする（CI でも同じ版を入れるため）
- 直すときは `mise run fix`（ruff の自動修正と format）

## 使い方（Go の例）

```bash
cd <新しいプロジェクト>
cp -R ~/.dotfiles/templates/common/. .
cp -R ~/.dotfiles/templates/go/. .
cat ~/.dotfiles/templates/common/.gitignore ~/.dotfiles/templates/go/.gitignore > .gitignore

# module-name / modulename を、プロジェクトの名前に置き換える
#   go.mod の module（module-name）、modulename.go と modulename_test.go のファイル名と package（modulename）
#   Go のパッケージ名にはハイフンが使えないので、package の方はハイフンを外す

mise trust            # この mise.toml を信頼する（新しい PC でも最初に 1回）
mise install          # go と pre-commit を入れる
pre-commit install
mise run check        # format・vet・速いテスト
```

- 依存は `go get <モジュール>`。固定は `go.sum` に任せ、`go.mod` と `go.sum` はコミットする
- 直すときは `mise run fix`（`go fmt`）
- コマンドを作るときは `main` パッケージを `cmd/<名前>/main.go` に置き、`go build -o bin/ ./cmd/...` でビルドする（`bin/` は `.gitignore` 済み）

## 使い方（Rust の例）

```bash
cd <新しいプロジェクト>
cp -R ~/.dotfiles/templates/common/. .
cp -R ~/.dotfiles/templates/rust/. .
cat ~/.dotfiles/templates/common/.gitignore ~/.dotfiles/templates/rust/.gitignore > .gitignore

# package-name / package_name を、プロジェクトの名前に置き換える
#   Cargo.toml の name（package-name）、src/lib.rs の最初のコメント（package_name）

mise trust            # この mise.toml を信頼する（新しい PC でも最初に 1回）
mise install          # rust（clippy・rustfmt を含む）と pre-commit を入れる
pre-commit install
mise run check        # format・clippy・テスト
```

- 依存は `cargo add <クレート>`。`Cargo.toml` には範囲（`cargo add` が書く形）を書き、固定は `Cargo.lock` に任せる。`Cargo.lock` はライブラリでもコミットする（CI でも同じ版を入れるため）
- 直すときは `mise run fix`（`cargo fmt`）
- コマンドを作るときは `src/main.rs` を足す（`src/lib.rs` と並べて置ける）

## 版を上げる（`../decisions/0008`）

| もの | いつ | どうやって |
|---|---|---|
| ライブラリと開発の道具（ruff・pyright・pytest など） | 作業を始めるとき（よく触るリポジトリは月 1回まで） | `mise run upgrade`（Python は `uv lock --upgrade`、Go は `go get -u -t ./...` → `go mod tidy`、Rust は `cargo update`。そのあと `mise run check`）。本来の作業とは別のコミットにする。落ちたらその場で直すか、そのライブラリだけ前の版に戻す（`uv lock --upgrade-package <名前>`・`go get <モジュール>@<版>` で 1つずつ扱う手もある） |
| プロジェクトの Python・uv・Go・Rust・pre-commit（Go と Rust のみ） | ひな形は毎年 11月（Python・Go・Rust を 1つの PR にまとめる）。既存のリポジトリは触るとき | `mise.toml` を書き換える。uv を上げたら `uv_build` の範囲も、Python を上げたら `requires-python` も、Go を上げたら `go.mod` の `go` の行も、Rust を上げたら `Cargo.toml` の `rust-version` も直す |
| セキュリティの問題があるライブラリ | 問題が見つかったとき | Dependabot の自動の修正 PR をマージする |
| mise 本体・プロジェクトの外の道具 | `mbrew` のたび | `brew upgrade` と `mise upgrade`（dotfiles の `mise/config.toml` は `latest`・`lts`） |

## メモ

- Python の版は `mise.toml` の `[tools]` だけで決める。uv が自分で Python を探さないよう、`[env]` で `UV_PYTHON_PREFERENCE = "only-system"` にしてある（入れないと、uv が mise とは別の版で仮想環境を作ることがあった。2026-11-03）
- ruff の `RUF001`〜`RUF003`（全角の文字を止めるルール）は外してある。docstring やコメントを日本語で書くため
- 型チェッカは pyright。ty が 1.0 になったら移るかを考える
- CI の `MISE_TRUSTED_CONFIG_PATHS` は、CI の上で mise がリポジトリの `mise.toml` を読むため（mise は信頼していない設定ファイルを読まない）
- `uv sync` をしなくても、`mise run check` の最初の `uv run` が仮想環境を作って依存を入れる。CI はこれに頼っている
- `pyproject.toml` は `readme = "README.md"` なので、README.md がないと uv がパッケージを作れない
- ひな形を直したら、dotfiles の CI（`.github/workflows/templates.yml`）が、ひな形を写したサンプルで同じ手順を GitHub 上で動かして確かめる
- 版の選び方（`../decisions/0007`）: Python は最新の 1つ前のマイナー版、Go と Rust は最新のマイナー版（Go は新しい版が 2つ出るとサポートが終わり、Rust は最新の stable だけがサポートされるため）。細かい版（パッチ）は固定しない。ひな形は毎年 11月に見直す
  - Python の版を書くのは `mise.toml` の `[tools]` と `pyproject.toml` の `requires-python` の 2か所。上げるときは両方を直す。pyright は仮想環境の Python から版を読むので書かない
  - uv の版と `pyproject.toml` の `uv_build` の範囲は組み。uv を上げたら `uv_build` の範囲も合わせる
  - Go の版を書くのは `mise.toml` の `[tools]` と `go.mod` の `go` の行（`1.27.0` の形）の 2か所。`toolchain` の行は書かない
  - マイナー版までしか書かないので、手元と CI で細かい版がずれることがある（2026-11-03 は手元 3.13.11、CI 3.13.18）。困ったら `mise.lock` に移る

### Go のメモ（2026-11-07）

- `[env]` で `GOPATH`・`GOCACHE`・`GOBIN` を `.go/` の下に置き、依存とキャッシュをプロジェクトの中に閉じ込める（既定ではホームの `~/go` や `~/Library/Caches/go-build`）
- `GOTOOLCHAIN = "local"` で、go が `go.mod` を見て別の版を落としてこないようにしている。版を決めるのは `mise.toml` だけ（Python の `UV_PYTHON_PREFERENCE` と同じ考え方）
- `check` の gofmt は `.go/` を外して見る。`gofmt -l .` だと `.go/` の下の依存まで見てしまう。`go vet ./...`・`go test ./...` は `.` で始まるフォルダを含めないのでそのままでよい
- mise のタスクの `run` には `{{ }}` を書けない（mise が自分のテンプレートとして読む）。`go list -f '{{.Dir}}'` などは使えない
- pre-commit は `[tools]` で mise が入れる。Python は開発用の依存で入るが、Go にはその仕組みがないため。mise が入れる pre-commit は Python で動く 1つのファイル（`.pyz`）なので、グローバルの Python（dotfiles の `mise/config.toml`）を使う
- テストは `go test -short` で速いものだけを動かす（Python の `-m 'not slow'` に当たる）。重いテストは `testing.Short()` で飛ばす

### Rust のメモ（2026-11-11）

- `[tools]` の rust は `components = "clippy,rustfmt"` を明示している。rustup の profile が `minimal` だと clippy と rustfmt が入らないため
- mise は rustup でツールチェーンを入れる。ツールチェーンは `~/.rustup`、依存のキャッシュは `~/.cargo` に置き、プロジェクトの中には閉じ込めない（Go の `.go/` とは違う）。ツールチェーンは 1つ数百 MB あり、プロジェクトごとに置くと重いため。ビルドの結果は元から `target/` に閉じている
- mise は `RUSTUP_TOOLCHAIN` を設定するので、`mise.toml` の版が使われる。`rust-toolchain.toml` は置かない（版を決める場所を 1か所にする）
- グローバル（dotfiles の `mise/config.toml`）には rust を入れていない。プロジェクトの外で `cargo` を呼ぶと mise の shim がエラーになる（`mbrew` の `brew bundle dump` には `--no-cargo` を付けてある）
- `Cargo.toml` の `rust-version` は `mise.toml` の版と同じにする。cargo（edition 2024 の resolver）は、依存を選ぶときにこの版で動くものを選ぶ
