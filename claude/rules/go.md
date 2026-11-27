---
paths:
  - "**/*.go"
  - "**/go.mod"
---

# Go コーディング規約

## 設計哲学 (Go Proverbs より)

- Clear is better than clever.（賢いコードより、読んで分かるコード）
- A little copying is better than a little dependency.（小さな依存を足すより、少し写す）
- The bigger the interface, the weaker the abstraction.（インターフェースは小さく）
- Errors are values.（エラーは値として扱い、返して処理する）
- Don't communicate by sharing memory, share memory by communicating.
- Make the zero value useful.（ゼロ値のままで使える型にする）

## コードスタイル

### 書式

- 書式（インデント・空白・並び）は `gofmt` に任せる。手で揃えない
- 行の長さに決まりはない。読みにくいほど長い行は、変数に分けるか関数に切り出す
- import は 標準ライブラリ → 外部 → このモジュールの中 の順にグループに分け、間に空行を入れる（`gofmt` はグループ分けまではしない）
- ドット import（`import . "pkg"`）は使わない。空の import（`import _ "pkg"`）は `main` とテストだけ

### 命名規則

| 要素 | 規則 | 例 |
|---|---|---|
| パッケージ | 小文字の短い 1語。アンダースコア・複数形にしない | `parser` |
| 公開する識別子 | MixedCaps（大文字で始める） | `ParseFile` |
| 公開しない識別子 | mixedCaps（小文字で始める） | `parseLine` |
| 頭字語 | 全部大文字か全部小文字 | `userID`・`URL`（`UserId` ✗） |
| インターフェース（メソッド 1つ） | メソッド名 + `-er` | `Reader` |
| エラーの変数・型 | `Err` で始める / `Error` で終わる | `ErrNotFound`・`ParseError` |
| レシーバ | 型名の 1〜2文字。型の中で揃える | `func (p *Parser)` |

- パッケージ名を繰り返さない: `parser.Parse`（`parser.ParseParser` ✗）
- getter に `Get` を付けない: `Owner()`（`GetOwner()` ✗）。setter は `SetOwner()`
- 短い名前は狭い範囲だけ（ループの `i`、レシーバ）。広い範囲で使うものほど意味のある名前にする

### コメント

- 公開する識別子には doc コメントを書き、その名前で始める: `// ParseFile は ...`
- パッケージには `// Package <名前> は ...` のコメントを 1か所に書く
- コメントは「なぜ」を書く（「何を」はコードが語る）

## 実装方針

### エラーハンドリング

- 失敗しうる関数は、最後の戻り値で `error` を返す
- エラーを `_` で捨てない。捨てるときは理由をコメントに書く
- 文脈を足して返すときは `fmt.Errorf("parse %s: %w", name, err)` で包む（`%w` で元のエラーを残す）
- エラーの比較は `errors.Is`、型で見るときは `errors.As`（`==` や型アサーションは使わない）
- エラーメッセージは小文字で始め、句点や改行で終えない
- `panic` は、プログラムの誤り（成り立つはずの条件が破れた）と、起動時の回復できない失敗だけ。ライブラリの公開 API からは `panic` を外に出さない
- 早めに return してネストを浅くする（`else` の中に正常の処理を書かない）

### 型とインターフェース

- インターフェースは使う側のパッケージで、必要なメソッドだけで定義する。引数はインターフェースで受け、戻り値は具体的な型で返す
- `any`（`interface{}`）は最小限に。型が決まるならジェネリクスか具体的な型を使う
- 列挙値は独自の型と `const` + `iota` で定義する（マジック文字列禁止）

### パッケージの状態

- パッケージのグローバル変数（変えられるもの）と `init()` は避ける。依存は引数や構造体のフィールドで渡す

### context と並行処理

- `context.Context` は第1引数 `ctx` で受け取る。構造体のフィールドに入れない
- goroutine を起こすときは、いつ・どうやって終わるかを決めてから書く（`ctx` の取り消し、`sync.WaitGroup`、`errgroup`）
- チャネルを閉じるのは送る側だけ
- 共有する値は、チャネルで渡すか `sync.Mutex` で守る

### ログ

- ログには `log/slog` を使う（`fmt.Println` や `log` ではなく）
- ライブラリのパッケージではログを出さず、エラーを返して呼び出し側に任せる

## テスト

- フレームワーク: 標準の `testing`。アサーションのライブラリは足さず、`if` と `t.Errorf` で書く
- テストファイル名: `<対象>_test.go`（対象と同じパッケージに置く）
- テスト関数名: `Test<対象>_<条件>`
- ケースが複数あるときはテーブル駆動にし、`t.Run` でケースに名前を付ける
- 失敗の表示は `got` と `want` を並べる: `t.Errorf("Parse(%q) = %v, want %v", in, got, want)`
- テストの補助関数には `t.Helper()` を書く。後片付けは `t.Cleanup`、一時フォルダは `t.TempDir()`
- 重いテストは `if testing.Short() { t.Skip(...) }` で飛ばせるようにする（`mise run check` は `-short` で動かす）

## 開発環境

- 開発環境（mise の版、依存とキャッシュを `.go/` に閉じ込める設定、pre-commit、CI）は、`~/.dotfiles/templates/common/` と `~/.dotfiles/templates/go/` のひな形のとおり。設定を変えるときは、ひな形のほうを直す（`~/.dotfiles/decisions/0002`）
- 使ってよい言語の機能は、プロジェクトの `mise.toml` の Go の版まで
- コードを書いたら `mise run check`（gofmt・go vet・速いテスト）を通す。直すときは `mise run fix`
