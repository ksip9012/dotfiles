# Python コーディング規約

## 設計哲学（PEP-20: Zen of Python）

```
Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently.
Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Now is better than never.
Although never is often better than right now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
```

## コードレイアウト（PEP-8）

- インデント: スペース4つ（タブ不可）
- 行長: **79文字以内**（docstring・コメントは72文字以内）
- 二項演算子は改行前に配置（`and`, `or`, `+` 等）
- トップレベルの関数・クラス定義の前後に空行2つ
- クラス内のメソッド間に空行1つ

## インポート

- ファイル先頭（モジュール docstring の後）に記述
- 1行1モジュール（`import os, sys` は不可）
- グループ順序（間に空行）:
  1. 標準ライブラリ
  2. サードパーティ
  3. ローカル
- 絶対インポートを優先
- ワイルドカードインポート（`from x import *`）禁止

## 命名規則

| 要素 | 規則 | 例 |
|---|---|---|
| パッケージ・モジュール | 小文字・アンダースコア可 | `my_module` |
| クラス | CapWords | `MyClass` |
| 例外 | CapWords + `Error` サフィックス | `ValueParseError` |
| 関数・変数 | 小文字 + アンダースコア | `my_function` |
| 定数 | 大文字 + アンダースコア | `MAX_RETRY` |
| 型変数 | CapWords・短い名前 | `T`, `AnyStr` |

**特殊な命名:**
- `_var`: 内部使用（非公開）
- `class_`: キーワードとの衝突回避
- `__var`: クラス内の名前マングリング
- `l`, `O`, `I` の単一文字変数は禁止

## 空白

- 括弧・ブラケット内に余分なスペースを入れない
- コンマ・コロン・セミコロンの前にスペースを入れない
- 関数呼び出しの括弧前にスペースを入れない（`func()` ○ / `func ()` ✗）
- 代入演算子・比較演算子の前後にスペース1つ
- デフォルト引数の `=` 前後にスペースなし: `def f(x=0):`
- アノテーション付きデフォルト引数はスペースあり: `def f(x: int = 0):`

## コメント・docstring

- 公開モジュール・クラス・関数・メソッドには必ず docstring を書く
- docstring はトリプルダブルクォート `"""` を使用
- インラインコメントは最小限に。自明なことは書かない
- コメントは「なぜ」を説明する（「何を」はコードが語る）

## 型ヒント

- すべての関数に引数・戻り値の型ヒントを付ける
- 変数アノテーション: `name: str = "value"`
- 戻り値アノテーション: `def func() -> int:`
- `None` を返す関数は `-> None` を明記

## ツール設定

### Ruff（Linter / Formatter）

```toml
# pyproject.toml
[tool.ruff]
line-length = 79

[tool.ruff.lint]
select = ["E", "F", "W", "I"]  # pycodestyle, pyflakes, isort
```

### pytest（テスト）

- テストファイル: `tests/test_*.py`
- テスト関数: `def test_*():`
- フィクスチャは `conftest.py` で管理

### uv + Poetry（パッケージ・バージョン管理）

- Python バージョン管理: `uv`
- 依存関係管理: `poetry`（`pyproject.toml`）
- 仮想環境は Poetry が管理

```bash
uv python install 3.12
poetry install
poetry add <package>
poetry add --group dev <package>
```

## ディレクトリ構成（src レイアウト）

```
project/
├── src/
│   └── package_name/
│       ├── __init__.py
│       └── module.py
├── tests/
│   ├── conftest.py
│   └── test_module.py
├── pyproject.toml
└── README.md
```
