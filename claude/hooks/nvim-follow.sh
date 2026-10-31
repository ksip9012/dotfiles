#!/bin/bash
#
# Claude Code の hook: Claude の作業を nvim に自動で追いかけさせる。
#   nvim-follow.sh open … PostToolUse (Edit/Write): 編集したファイルを開き、変更した行へ移動する
#   nvim-follow.sh view … PostToolUse (Read): プロジェクト内のテキストファイルを読んだら、読んだ位置を開く
#   nvim-follow.sh mark … UserPromptSubmit: ターンの始まりを nvim に記録する
#   nvim-follow.sh sync … Stop: 開いているファイルを読み込み直し、Bash などで変わったファイルも開く
#   nvim-follow.sh guard … PreToolUse (Bash): プロジェクト内のファイルを cat などで読むだけなら止め、Read を使わせる
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

# Bash のコマンドが、プロジェクト内のテキストファイルを読むだけのものか
# （cat・bat・less・more・head・tail・sed -n 'Np' にファイルを渡すだけ。パイプなどがあれば対象外）
reads_project_text() {
    case "$1" in
        '' | *[\|\;\&\<\>\$\`\(\)]* | *$'\n'*) return 1 ;;
    esac
    # 上で区切り文字や置換を除いてあるので、eval はクォートを解くだけになる
    set -f
    eval "set -- $1" 2>/dev/null || return 1
    set +f

    local cmd=$1 arg files=0
    shift
    case "$cmd" in
        cat | bat | less | more | head | tail) ;;
        sed)
            [ "$1" = -n ] && [[ "$2" =~ ^[0-9]+(,[0-9]+)?p$ ]] || return 1
            shift 2
            ;;
        *) return 1 ;;
    esac
    while [ $# -gt 0 ]; do
        arg=$1
        shift
        case "$cmd:$arg" in
            head:-[nc] | tail:-[nc]) shift; continue ;; # 行数・バイト数の引数を飛ばす
            *:-*) continue ;;
        esac
        case "$(realpath "$arg" 2>/dev/null)" in
            "$project_dir"/*) ;;
            *) return 1 ;;
        esac
        [ -f "$arg" ] && grep -Iq . "$arg" 2>/dev/null || return 1
        files=$((files + 1))
    done
    [ "$files" -gt 0 ]
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
        # （プロジェクト内でも .claude/ などの隠しディレクトリにあるものは開かない）
        case "$(realpath "$file_path" 2>/dev/null)" in
            "$project_dir"/.* | "$project_dir"/*/.*) exit 0 ;;
            "$project_dir"/*) ;;
            *) exit 0 ;;
        esac
        grep -Iq . "$file_path" 2>/dev/null || exit 0
        line=$(jq -r '.tool_input.offset // 1' <<<"$input" 2>/dev/null)
        [[ "$line" =~ ^[0-9]+$ ]] || line=1
        expr="v:lua.require'core.claude'.view($(quote "$file_path"), $line)"
        ;;
    guard)
        input=$(cat)
        command=$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null)
        cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)
        cd "${cwd:-$project_dir}" 2>/dev/null || exit 0
        reads_project_text "$command" || exit 0
        jq -n --arg reason "Neovim が Claude の作業を追いかけているので、プロジェクト内のファイルは Bash ではなく Read ツールで読んでください（Read で読むと Neovim でも開きます）。範囲を絞るときは offset・limit を使ってください。" \
            '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
        exit 0
        ;;
    mark) expr="v:lua.require'core.claude'.mark()" ;;
    sync) expr="v:lua.require'core.claude'.sync()" ;;
    *) exit 0 ;;
esac

nvim --server "$server" --remote-expr "$expr" >/dev/null 2>&1
exit 0
