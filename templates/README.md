# 開発のひな形

新しいプロジェクトに置く土台のファイル。共通の部分（`common/`）と、言語ごとの部分（`python/` など）に分けてある。決めた理由は `../decisions/` の ADR。

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
└── python/                      # Python のプロジェクトに足す
    ├── .gitignore               # Python の部分（common の .gitignore に足す）
    ├── mise.toml                # [tools] の版と [tasks] の check・fix
    ├── pyproject.toml           # ruff・pyright・pytest の設定と、開発用の依存
    ├── src/package_name/__init__.py
    └── tests/test_import.py
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
- 依存は `uv add <パッケージ>`（開発用は `uv add --dev`）。`uv.lock` はコミットする（CI でも同じ版を入れるため）
- 直すときは `mise run fix`（ruff の自動修正と format）

## メモ

- Python の版は `mise.toml` の `[tools]` だけで決める。uv が自分で Python を探さないよう、`[env]` で `UV_PYTHON_PREFERENCE = "only-system"` にしてある（入れないと、uv が mise とは別の版で仮想環境を作ることがあった。2026-11-03）
- ruff の `RUF001`〜`RUF003`（全角の文字を止めるルール）は外してある。docstring やコメントを日本語で書くため
- 型チェッカは pyright。ty が 1.0 になったら移るかを考える
- CI の `MISE_TRUSTED_CONFIG_PATHS` は、CI の上で mise がリポジトリの `mise.toml` を読むため。ひな形を使った最初のリポジトリの CI で、これで動くかを確かめる
