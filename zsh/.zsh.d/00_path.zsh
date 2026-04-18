# Zsh のパスと XDG Base Directory 関連の設定

# 指定したパスが重複している場合には読み込まない
add_to_path_if_not_exists() {
  case ":$PATH:" in
  *":$1:"*) ;;
  *) export PATH="$1:$PATH";;
  esac
}

add_to_path_if_not_exists "/usr/local/bin"
add_to_path_if_not_exists "/usr/local/sbin"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Create necessary directories if they don't exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"
mkdir -p "$XDG_STATE_HOME/zsh" "$XDG_CACHE_HOME/zsh" "$XDG_DATA_HOME/z"

# --- Zsh 設定 (XDG準拠) ---
# macOS Terminal.app Zsh session disable
export SHELL_SESSION_HISTORY=0

# z.sh data path
export _Z_DATA="$XDG_DATA_HOME/z/data"

# --- アプリケーション別設定 (XDG準拠) ---
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export MPLCONFIGDIR="$XDG_CONFIG_HOME/matplotlib"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/history"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export PSQL_HISTORY="$XDG_STATE_HOME/psql/history"

# --- その他の設定 ---
# Antigravity (XDG準拠のパス)
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/antigravity/antigravity/bin:$PATH"

# Google Cloud CLI 用の Python 指定
export CLOUDSDK_PYTHON="/usr/local/bin/python3.13"
