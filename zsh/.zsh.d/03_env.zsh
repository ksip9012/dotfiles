export RUST_BACKTRACE=1

# エディタ（Claude Code の Ctrl+G などで使われる）
export EDITOR=nvim
export VISUAL=nvim

# Terraform (XDG compliance)
export TF_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/terraform"
export TF_PLUGIN_CACHE_DIR="$TF_DATA_DIR/plugin-cache"
