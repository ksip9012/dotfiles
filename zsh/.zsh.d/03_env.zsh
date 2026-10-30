export RUST_BACKTRACE=1

# エディタ（Claude Code の Ctrl+G などで使われる）
export EDITOR=nvim
export VISUAL=nvim

# Homebrew: 固まったダウンロードを打ち切る curl 設定（brew.env は変数展開しないためここで設定）
export HOMEBREW_CURLRC="${XDG_CONFIG_HOME:-$HOME/.config}/homebrew/curlrc"

# Terraform (XDG compliance)
export TF_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/terraform"
export TF_PLUGIN_CACHE_DIR="$TF_DATA_DIR/plugin-cache"
