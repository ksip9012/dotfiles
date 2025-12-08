#!/bin/bash
#
# install.sh
# This script creates symlinks from the home directory to the dotfiles in this repository.

# Get the absolute path to the dotfiles directory, which is the directory of this script.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR=$HOME

echo "🚀 Starting dotfiles setup..."
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Home directory:     $HOME_DIR"
echo ""

# --- Helper function for creating symlinks ---
# $1: source file in dotfiles repo
# $2: target file in home directory
link_file() {
    local source_path="$1"
    local target_path="$2"
    local target_dir

    # Create parent directory of target if it doesn't exist
    target_dir=$(dirname "$target_path")
    mkdir -p "$target_dir"

    # Create the symlink
    # -s: symbolic
    # -f: force (overwrite)
    # -n: no-dereference (treat symlink to dir as a file)
    # -v: verbose
    ln -sfnv "$source_path" "$target_path"
}

# Homebrewパッケージのインストール（例: macOSの場合）
if command -v brew >/dev/null 2>&1; then
    echo ""
    echo "📦 Installing Homebrew packages via Brewfile..."
    # Brewfileが .dotfiles ディレクトリ直下にあると仮定
    brew bundle --file="$DOTFILES_DIR/Brewfile"
else
    echo "⚠️ Homebrew not found. Skipping package installation."
fi

# --- Link configuration files ---

echo "Linking configuration files..."

# Zsh
link_file "$DOTFILES_DIR/zsh/.zshrc"              "$HOME_DIR/.zshrc"

# WezTerm
link_file "$DOTFILES_DIR/wezterm/.wezterm.lua"      "$HOME_DIR/.wezterm.lua"

# Starship
# Note: .zshrc points to the file in dotfiles repo directly, but creating a symlink
# is a more robust method for other shells or if the env var is not set.
link_file "$DOTFILES_DIR/starship/.starship.toml"  "$HOME_DIR/.config/starship.toml"

# Mise
link_file "$DOTFILES_DIR/mise/config.toml"         "$HOME_DIR/.config/mise/config.toml"

# Sheldon
link_file "$DOTFILES_DIR/sheldon/plugins.toml"     "$HOME_DIR/.config/sheldon/plugins.toml"

# Newsboat
link_file "$DOTFILES_DIR/newsboat/config"          "$HOME_DIR/.newsboat/config"
link_file "$DOTFILES_DIR/newsboat/urls"            "$HOME_DIR/.newsboat/urls"

# nvim
link_file "$DOTFILES_DIR/nvim" "$HOME_DIR/.config/nvim"

# Visual Studio Code (macOS only)
if [[ "$(uname)" == "Darwin" ]]; then
    echo ""
    echo "Linking Visual Studio Code settings (macOS)..."
    VSCODE_USER_DIR="$HOME_DIR/Library/Application Support/Code/User"
    link_file "$DOTFILES_DIR/.vscode/settings.json"    "$VSCODE_USER_DIR/settings.json"
    link_file "$DOTFILES_DIR/.vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
fi

echo ""
echo "✅ Dotfiles setup complete!"
