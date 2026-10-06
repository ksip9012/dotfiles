# Global Claude Code Rules

- 回答はすべて**日本語**で行う。
- 環境: macOS、Shell は zsh。
- dotfiles は `~/.dotfiles/` で XDG Base Directory Specification に準拠して管理している。
- 追加で利用可能な CLI: `rg`, `fd`, `bat`, `eza`, `jq`, `fzf`, `zoxide`, `gh`, `rip`。必要に応じて直接呼び出してよい。
- Claude Code のシェルでは標準コマンドを上書きするエイリアス（`ls`→eza など）は無効化している。標準コマンドは通常の挙動で使える。
- Skill（`SKILL.md`）を新規作成・改修する際は `~/.claude-skills/SKILL_DESIGN_GUIDE.md` のチェックリストを参照する。
