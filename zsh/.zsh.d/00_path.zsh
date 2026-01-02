# 指定したパスが重複している場合には読み込まない
add_to_path_if_not_exists() {
  case ":$PATH:" in
  *":$1:"*) ;;
  *) export PATH="$1:$PATH";;
  esac
}

add_to_path_if_not_exists "/usr/local/bin"
add_to_path_if_not_exists "/usr/local/sbin"

# starship 関係
export STARSHIP_CONFIG="$HOME/.dotfiles/starship/.starship.toml"
# Antigravity 関係
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
