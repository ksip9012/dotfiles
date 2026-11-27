---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---

# Rust コーディング規約

## 設計哲学

- 型で不正な状態を表せないようにする（`Option`・`enum`・newtype）
- 失敗は `Result` で返し、呼び出し側に扱わせる
- 所有権は必要なところだけ取り、ほかは借用で渡す
- コンパイラと clippy の警告は、黙らせずに直す

## コードスタイル

### 書式

- 書式（インデント・行の長さ・import の並び）は `rustfmt` に任せる。手で揃えない
- `clippy` の警告を残さない（`mise run check` は `-D warnings` で落とす）。どうしても外すときは、いちばん狭い範囲に `#[allow(clippy::...)]` を付け、理由をコメントに書く
- `use` は 標準ライブラリ → 外部のクレート → このクレートの中（`crate::`）の順にグループに分ける。グロブ（`use foo::*`）は `prelude` とテストの `use super::*` だけ

### 命名規則 (Rust API Guidelines)

| 要素 | 規則 | 例 |
|---|---|---|
| クレート・モジュール | snake_case | `my_crate` |
| 型・トレイト・enum の値 | UpperCamelCase | `HttpClient` |
| 関数・メソッド・変数 | snake_case | `parse_line` |
| 定数・static | SCREAMING_SNAKE_CASE | `MAX_RETRY` |
| 型引数 | 短い UpperCamelCase | `T`・`K` |
| ライフタイム | 短い小文字 | `'a` |

- 頭字語は 1語として扱う: `Uuid`・`HttpClient`（`UUID`・`HTTPClient` ✗）
- getter に `get_` を付けない: `fn name(&self)`（`fn get_name` ✗）
- 変換のメソッド名は、コストと所有権で使い分ける: `as_`（借用・軽い）、`to_`（コピーして作る）、`into_`（所有権を取る）
- 意味のある名前を使う。1文字はクロージャの引数やループなど、範囲が狭いときだけ

### コメント

- 公開する項目には `///` の doc コメントを書く。クレートとモジュールの説明は `//!`
- 失敗やパニックがある関数は、doc コメントに `# Errors`・`# Panics` の節を書く
- コメントは「なぜ」を書く（「何を」はコードが語る）

## 実装方針

### エラーハンドリング

- 失敗しうる関数は `Result` を返し、伝えるときは `?` を使う
- `unwrap()` はテストだけ。本体では、成り立つ理由を書いた `expect("...")` にする
- `panic!` は、プログラムの誤り（成り立つはずの条件が破れた）だけ
- ライブラリは、自分のエラー型（`enum`）を作って `std::error::Error` を実装する。アプリは呼び出し側で文脈を足してまとめてよい
- エラーを捨てない（`let _ = ...` で `Result` を無視しない。無視するときは理由をコメントに書く）

### 所有権と借用

- 引数は借用で受ける: `&str`（`&String` ✗）、`&[T]`（`&Vec<T>` ✗）
- `clone()` は借用で済まないときだけ。借用チェッカーを黙らせるための `clone()` は避ける
- 返す値は所有権ごと返す（呼び出し側が使いやすいように）

### 型とデータ構造

- 列挙値は `enum` で定義する（マジック文字列・マジックナンバー禁止）。`match` は `_` で受けず、すべての値を書く（値を足したときにコンパイラが教えてくれる）
- 意味の違う同じ型の値は newtype で分ける: `struct UserId(u64);`
- 公開する範囲は最小限にする（まず `pub(crate)`、外から使うものだけ `pub`）
- 構造体には、意味のあるものだけ `#[derive(Debug, Clone, PartialEq)]` などを付ける。公開する型には `Debug` を付ける

### unsafe

- `unsafe` は使わない。どうしても使うときは、すぐ上に `// SAFETY:` で成り立つ理由を書く

### ログ

- 本体のコードで `println!` をログの代わりに使わない。ログを出すときは、ログのクレートを 1つ決めて使う（足すときは Issue で決める）

## テスト

- フレームワーク: 標準のテスト（`#[test]`・`cargo test`）
- 単体テストは同じファイルの `#[cfg(test)] mod tests` に書き、`use super::*;` で対象を読み込む
- 公開 API を外から試す結合テストは `tests/` に置く
- テスト関数名: `<対象>_<条件>_<期待結果>`（snake_case）
- AAA パターン（Arrange / Act / Assert）で書き、比較は `assert_eq!(got, want)` の順にする
- 重いテストには `#[ignore = "理由"]` を付ける（`mise run check` の `cargo test` では動かさない）

## 開発環境

- 開発環境（mise の版と clippy・rustfmt、pre-commit、CI）は、`~/.dotfiles/templates/common/` と `~/.dotfiles/templates/rust/` のひな形のとおり。設定を変えるときは、ひな形のほうを直す（`~/.dotfiles/decisions/0002`）
- 使ってよい言語の機能は、プロジェクトの `Cargo.toml` の `edition` と `rust-version` まで
- コードを書いたら `mise run check`（cargo fmt --check・clippy・テスト）を通す。直すときは `mise run fix`
