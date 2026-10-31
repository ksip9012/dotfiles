#!/bin/bash
#
# Claude Code の hook: Claude の作業を nvim に自動で追いかけさせる。
#   nvim-follow.sh open … PostToolUse (Edit/Write): 編集したファイルを開き、変更した行へ移動する
#   nvim-follow.sh view … PostToolUse (Read): プロジェクト内のテキストファイルを読んだら、読んだ位置を開く
#   nvim-follow.sh mark … UserPromptSubmit: ターンの始まりを nvim に記録する
#   nvim-follow.sh sync … Stop: 開いているファイルを読み込み直し、Bash などで変わったファイルも開く
# 送り先の nvim:
# 1. nvim の :terminal 内で動いていれば ($NVIM) その nvim
# 2. それ以外はプロジェクトディレクトリで起動した nvim（nvim/lua/core/claude.lua）
# どちらもなければ何もしない。hook の失敗で Claude Code を止めないよう常に 0 で終わる。

project_dir=$(realpath "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null) || exit 0
server="$NVIM"
if [ -z "$server" ]; then
    hash=$(printf '%s' "$project_dir" | shasum -a 256 | cut -c1-12)
    server="${XDG_STATE_HOME:-$HOME/.local/state}/nvim/claude/$hash.sock"
fi
[ -S "$server" ] || exit 0

# Vim script の文字列リテラル用に ' を '' にエスケープして囲む
quote() {
    local escaped=${1//\'/\'\'}
    printf "'%s'" "$escaped"
}

case "$1" in
    open)
        input=$(cat)
        file_path=$(jq -r '.tool_input.file_path // empty' <<<"$input" 2>/dev/null)
        [ -n "$file_path" ] || exit 0
        # 移動先の目印: 書き込んだ文字列のうち、空白だけでない最初の行
        needle=$(jq -r '(.tool_input.new_string // .tool_input.edits[0].new_string // "")
            | split("\n") | map(select(test("\\S"))) | .[0] // ""' <<<"$input" 2>/dev/null)
        expr="v:lua.require'core.claude'.open($(quote "$file_path"), $(quote "$needle"))"
        ;;
    view)
        input=$(cat)
        file_path=$(jq -r '.tool_input.file_path // empty' <<<"$input" 2>/dev/null)
        # スキルや設定ファイルまで開かないよう、プロジェクト内のテキストファイルに限る
        case "$(realpath "$file_path" 2>/dev/null)" in
            "$project_dir"/*) ;;
            *) exit 0 ;;
        esac
        grep -Iq . "$file_path" 2>/dev/null || exit 0
        line=$(jq -r '.tool_input.offset // 1' <<<"$input" 2>/dev/null)
        [[ "$line" =~ ^[0-9]+$ ]] || line=1
        expr="v:lua.require'core.claude'.view($(quote "$file_path"), $line)"
        ;;
    mark) expr="v:lua.require'core.claude'.mark()" ;;
    sync) expr="v:lua.require'core.claude'.sync()" ;;
    *) exit 0 ;;
esac

nvim --server "$server" --remote-expr "$expr" >/dev/null 2>&1
exit 0
