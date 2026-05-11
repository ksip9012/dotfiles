# Python コーディング規約

## 設計哲学 (PEP-20: Zen of Python)

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

## コードスタイル

### コードレイアウト (PEP-8)

- インデント: スペース4つ (タブ不可)
- 行長: **88文字以内**
- 二項演算子は行頭に配置 (`and`, `or`, `+` 等)
- 文字列の連結は行頭で揃える
- トップレベルの関数・クラス定義の前後に空行2つ
- クラス内のメソッド間に空行1つ

### インポート

- インポートの並び・グループ化は Ruff の `I` ルールに従う
  - グループ順序: 標準ライブラリ → サードパーティ → ローカル (間に空行)
- ワイルドカードインポート (`from x import *`) 禁止
- 絶対インポートを使用 (同一パッケージ内のみ相対インポート可)
- 1行1モジュール (`import os, sys` は不可)

### 命名規則

| 要素 | 規則 | 例 |
|---|---|---|
| パッケージ・モジュール | 小文字・アンダースコア可 | `my_module` |
| クラス | CapWords | `MyClass` |
| 例外 | CapWords + `Error` サフィックス | `ValueParseError` |
| 関数・変数 | 小文字 + アンダースコア | `my_function` |
| 定数 | 大文字 + アンダースコア | `MAX_RETRY` |
| 型変数 | CapWords・短い名前 | `T`, `AnyStr` |

#### 特殊な命名

- `_var`: 内部使用 (非公開)
- `class_`: キーワードとの衝突回避
- `__var`: クラス内の名前マングリング
- 意味のある名前を使う。ループカウンタや座標など慣用的な場合を除き、単一文字変数は避ける
- `l`, `O`, `I` の等の `1` や `0` 等との区別のつきにくい変数は禁止

### 空白

- 括弧・ブラケット内に余分なスペースを入れない
- コンマ・コロン・セミコロンの前にスペースを入れない
- 関数呼び出しの括弧前にスペースを入れない (`func()` ○ / `func ()` ✗)
- 代入演算子・比較演算子の前後にスペース1つ
- デフォルト引数の `=` 前後にスペースなし: `def f(x=0):`
- アノテーション付きデフォルト引数はスペースあり: `def f(x: int = 0):`

### コメント・docstring

- 公開モジュール・クラス・関数・メソッドには必ず docstring を書く
- docstring はトリプルダブルクォート `"""` を使用
- インラインコメントは最小限に。自明なことは書かない
- コメントは「なぜ」を説明する (「何を」はコードが語る)
- docstring は google style で記述する

#### docstring 例 (Google style)

```python
def fetch_user(user_id: int, *, include_deleted: bool = False) -> User:
    """指定IDのユーザを取得する。

    Args:
        user_id: 取得対象のユーザID。
        include_deleted: 論理削除済みも含めるかどうか。

    Returns:
        ユーザオブジェクト。

    Raises:
        UserNotFoundError: 該当ユーザが存在しない場合。
    """
```

- 1行目は要約、空行を挟んで詳細
- `Args:` `Returns:` `Raises:` セクションを使用
- 型情報は型ヒントに任せ、docstring に重複させない

## 型システム

### 型ヒント

- 対象 Python バージョン: 3.13 以上
- 組み込みジェネリクス使用: `list[int]` (`List[int]` ではなく)
- Union は `X | Y` 構文 (`Union[X, Y]` ではなく)
- Optional は `X | None` (`Optional[X]` ではなく)
- `from __future__ import annotations` は不要
- `Any` の使用は最小限に
- 公開 API には型ヒント必須、内部関数も推奨
- 変数アノテーション: `name: str = "value"`
- 戻り値アノテーション: `def func() -> int:`
- `None` を返す関数は `-> None` を明記

### データ構造

- 構造化データには `dataclass` または `pydantic.BaseModel` を使用
- イミュータブルが望ましい場合は `frozen=True` または `NamedTuple`
- 単純な dict での値受け渡しは避ける (型安全性のため)
- 列挙値には `Enum` または `StrEnum` を使用 (マジック文字列禁止)

## 実装方針

### エラーハンドリング

- 裸の `except:` 禁止、`except Exception:` も最終手段
- 例外は具体的に捕捉する: `except ValueError:`
- 例外を握りつぶさない (`pass` だけの except は禁止)
- 再送出時は `raise` を使う (スタックトレース保持)
- 例外チェーンには `raise X from e` を使う
- カスタム例外は適切な基底クラスを継承

### 文字列フォーマット

- 文字列補間は f-string を使用 (`%` や `.format()` ではなく)
- ログメッセージは遅延評価のため `%` 形式を維持: `logger.info("user %s", name)`

### I/O

- パス操作には `pathlib.Path` を使用 (`os.path` ではなく)
- ファイル操作は `with` 文で必ずリソース管理
- エンコーディングは明示: `open(path, encoding="utf-8")`

### ロギング

- `print()` ではなく `logging` を使用
- ロガーは `logger = logging.getLogger(__name__)` で取得
- ログレベルを適切に使い分ける (DEBUG / INFO / WARNING / ERROR / CRITICAL)
- 例外ログには `logger.exception()` を使用 (スタックトレース自動付与)

## テスト

- フレームワーク: pytest
- テストファイル名: `test_*.py`
- テスト関数名: `test_<対象>_<条件>_<期待結果>`
- AAA パターン (Arrange / Act / Assert) で記述
- フィクスチャは `conftest.py` に集約
- パラメタライズは `@pytest.mark.parametrize` を使用
- 重いテストには `@pytest.mark.slow` を付与 (pre-commitでスキップ)
- 外部サービス依存テストには `@pytest.mark.integration` を付与

## 開発環境

### ディレクトリ構成 (src レイアウト)

#### 構成例

```
project/
├── src/
│   └── package_name/
│       ├── __init__.py
│       ├── py.typed          # 型ヒント配布のマーカー (ライブラリの場合)
│       └── module.py
├── tests/
│   ├── conftest.py
│   └── test_module.py
├── .pre-commit-config.yaml
├── .python-version           # mise/uv が読む (mise.toml の代わりも可)
├── mise.toml
├── pyproject.toml
├── uv.lock                   # uv が生成 (コミット対象)
├── .gitignore
└── README.md
```

### mise + uv (バージョン・パッケージ管理)

- Python 本体のバージョン管理: `mise`
- 依存関係・仮想環境管理: `uv`
- プロジェクト設定: `pyproject.toml` + `mise.toml` (または `.tool-versions`)
- `uv.lock` はコミットする (アプリケーション開発の場合)

#### mise.toml 例

```toml
[tools]
python = "3.13"
```

#### bash コマンド例

```bash
# 初回セットアップ
mise install              # mise.toml に従って Python をインストール
uv sync                   # 依存関係インストール（仮想環境 .venv を自動作成）

# パッケージ管理
uv add <package>          # 本番依存に追加
uv add --dev <package>    # 開発依存に追加
uv remove <package>       # パッケージ削除

# 実行
uv run python script.py   # 仮想環境内で実行
uv run pytest             # テスト実行
```

### Linter / Formatter (Ruff)

- linter: `ruff check`
- formatter: `ruff format`
- コミット前に両方実行する

#### pyproject.toml 例

```toml
[tool.ruff]
line-length = 88

[tool.ruff.lint]
select = [
  "E",     # pycodestyle errors
  "W",     # pycodestyle warnings
  "F",     # pyflakes
  "I",     # isort
  "B",     # flake8-bugbear
  "UP",    # pyupgrade
  "SIM",   # flake8-simplify
  "N",     # pep8-naming
  "RUF",   # Ruff
]
```

### 型チェッカ (pyright)

- 静的型チェック: `pyright`
- pre-commit およびCIで実行
- 1.0 リリース後に `ty` への移行を検討予定 (README.md 参照)

#### pyproject.toml 例

```toml
[tool.pyright]
pythonVersion = "3.13"
typeCheckingMode = "strict"
include = ["src", "tests"]
exclude = ["**/__pycache__", "**/.venv"]
reportMissingTypeStubs = false
```

### pre-commit

- [pre-commit](https://pre-commit.com) フレームワークを使用し、以下を実行する：
  - `ruff check --fix`
  - `ruff format`
  - `pyright`
  - `pytest` (軽量なもののみ)

#### .pre-commit-config.yaml 例

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.0  # 最新のタグに合わせる
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
  - repo: https://github.com/RobertCraigie/pyright-python
    rev: v1.1.390  # 最新のタグに合わせる
    hooks:
      - id: pyright
  - repo: local
    hooks:
      - id: pytest
        name: pytest (fast)
        entry: uv run pytest -m "not slow"
        language: system
        pass_filenames: false
```
