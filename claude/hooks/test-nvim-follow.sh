#!/bin/bash
# nvim-follow.sh mark の「ほかのディレクトリの nvim を知らせる」を試す。
# 使い方: bash test-nvim-follow.sh [nvim-follow.sh のパス]（省略すると同じフォルダのもの）
# 普段の nvim には触れない（XDG_STATE_HOME を試し用の場所に替える）。
hook=${1:-$(dirname "$0")/nvim-follow.sh}
T=/tmp/nf-test.$$
mkdir -p "$T/state/nvim/claude" "$T/home" "$T/proj"
export XDG_STATE_HOME=$T/state TMPDIR=$T CLAUDE_PROJECT_DIR=$T/proj
unset NVIM
sockdir=$T/state/nvim/claude
h=$(printf '%s' "$(realpath "$T/proj")" | shasum -a 256 | cut -c1-12)
pass=0 fail=0
check() { # 名前 期待(empty|notice) 出力
    local got=empty
    [ -n "$3" ] && got=notice
    if [ "$got" = "$2" ]; then pass=$((pass + 1)); echo "ok   $1"; else fail=$((fail + 1)); echo "NG   $1（期待 $2 / 実際 $got）: $3"; fi
}
start() { (cd "$1" && nvim --clean --headless --listen "$2" >/dev/null 2>&1 &); for _ in 1 2 3 4 5 6 7 8 9 10; do [ -S "$2" ] && return; sleep 0.2; done; }
stop() { nvim --server "$1" --remote-expr 'execute("qa!")' >/dev/null 2>&1; rm -f "$1"; }

check "nvim なし" empty "$(echo '{"session_id":"a"}' | bash "$hook" mark)"

python3 -c "import socket,sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])" "$sockdir/stale.sock"
check "残骸のソケットだけ" empty "$(echo '{"session_id":"a"}' | bash "$hook" mark)"
rm -f "$sockdir/stale.sock"

start "$T/home" "$sockdir/home.sock"
out=$(echo '{"session_id":"a"}' | bash "$hook" mark)
check "別ディレクトリの nvim" notice "$out"
echo "     systemMessage: $(jq -r .systemMessage <<<"$out")"
jq -e '.hookSpecificOutput.hookEventName == "UserPromptSubmit"' <<<"$out" >/dev/null || { fail=$((fail + 1)); echo "NG   JSON の形"; }
check "同じ会話の 2回目" empty "$(echo '{"session_id":"a"}' | bash "$hook" mark)"
check "別の会話" notice "$(echo '{"session_id":"b"}' | bash "$hook" mark)"
check "open では出さない" empty "$(echo '{"session_id":"c","tool_input":{"file_path":"x"}}' | bash "$hook" open)"

start "$T/proj" "$sockdir/$h.sock"
check "プロジェクトの nvim がある" empty "$(echo '{"session_id":"a"}' | bash "$hook" mark)"
stop "$sockdir/$h.sock"
check "つながったあとにまた外れたら知らせ直す" notice "$(echo '{"session_id":"a"}' | bash "$hook" mark)"

stop "$sockdir/home.sock"
rm -rf "$T"
echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
