#!/bin/bash
#
# Claude Code の PostToolUse hook: 編集したファイルを nvim で開く。
# 1. nvim の :terminal 内で動いていれば ($NVIM) その nvim
# 2. それ以外はプロジェクトディレクトリで起動した nvim（nvim/lua/core/claude.lua）
# どちらもなければ何もしない。hook の失敗で Claude Code を止めないよう常に 0 で終わる。

file_path=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$file_path" ] || exit 0

server="$NVIM"
if [ -z "$server" ]; then
    project_dir=$(realpath "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null) || exit 0
    hash=$(printf '%s' "$project_dir" | shasum -a 256 | cut -c1-12)
    server="${XDG_STATE_HOME:-$HOME/.local/state}/nvim/claude/$hash.sock"
fi
[ -S "$server" ] || exit 0

# Vim script の文字列リテラル用に ' を '' にエスケープ
escaped=${file_path//\'/\'\'}
nvim --server "$server" \
    --remote-expr "v:lua.require'core.claude'.open('$escaped')" \
    >/dev/null 2>&1
exit 0
