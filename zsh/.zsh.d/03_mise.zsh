export RUST_BACKTRACE=1

# Terraform (XDG compliance)
export TF_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/terraform"
export TF_PLUGIN_CACHE_DIR="$TF_DATA_DIR/plugin-cache"
