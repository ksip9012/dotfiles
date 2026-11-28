export RUST_BACKTRACE=1

# エディタ（Claude Code の Ctrl+G などで使われる）
export EDITOR=nvim
export VISUAL=nvim

# Homebrew: 固まったダウンロードを打ち切る curl 設定（brew.env は変数展開しないためここで設定）
export HOMEBREW_CURLRC="${XDG_CONFIG_HOME:-$HOME/.config}/homebrew/curlrc"

# Terraform (XDG compliance)
# TF_DATA_DIR はプロジェクトごとの .terraform/ に任せる（共有すると backend の設定が混ざる、#139）
# キャッシュのフォルダは Terraform が作らないので install.sh で作る
export TF_PLUGIN_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/terraform/plugin-cache"
