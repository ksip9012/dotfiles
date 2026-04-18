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
# $1: source file/dir in dotfiles repo
# $2: target file/dir in home directory
link_file() {
    local source_path="$1"
    local target_path="$2"
    local target_dir

    # Check if source exists
    if [ ! -e "$source_path" ]; then
        echo "⚠️ Skipping: Source $source_path does not exist."
        return
    fi

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

# --- Homebrew Setup ---
if command -v brew >/dev/null 2>&1; then
    if [ -f "$DOTFILES_DIR/Brewfile" ]; then
        echo "📦 Installing Homebrew packages via Brewfile..."
        brew bundle --file="$DOTFILES_DIR/Brewfile"
    fi
else
    echo "⚠️ Homebrew not found. Skipping package installation."
fi

# --- Link configuration files ---

echo ""
echo "🔗 Linking configuration files..."

# Zsh
link_file "$DOTFILES_DIR/zsh/.zshrc"              "$HOME_DIR/.zshrc"
link_file "$DOTFILES_DIR/zsh/.zsh.d"              "$HOME_DIR/.zsh.d"

# Git
link_file "$DOTFILES_DIR/git/.config/git/config"  "$HOME_DIR/.config/git/config"

# WezTerm
link_file "$DOTFILES_DIR/wezterm/.wezterm.lua"      "$HOME_DIR/.wezterm.lua"

# Starship
link_file "$DOTFILES_DIR/starship/.starship.toml"  "$HOME_DIR/.config/starship.toml"

# Directory-based configurations (Modern Tools)
link_file "$DOTFILES_DIR/mise"                     "$HOME_DIR/.config/mise"
link_file "$DOTFILES_DIR/sheldon"                  "$HOME_DIR/.config/sheldon"
link_file "$DOTFILES_DIR/raycast"                  "$HOME_DIR/.config/raycast"
link_file "$DOTFILES_DIR/nvim"                     "$HOME_DIR/.config/nvim"
link_file "$DOTFILES_DIR/aerospace"                "$HOME_DIR/.config/aerospace"

# Newsboat (If exists)
link_file "$DOTFILES_DIR/newsboat"                 "$HOME_DIR/.newsboat"

# Claude Code
link_file "$DOTFILES_DIR/claude/settings.json"     "$HOME_DIR/.claude/settings.json"
link_file "$DOTFILES_DIR/claude/CLAUDE.md"         "$HOME_DIR/.claude/CLAUDE.md"

# --- Visual Studio Code (macOS only) ---
if [[ "$(uname)" == "Darwin" ]]; then
    VSCODE_USER_DIR="$HOME_DIR/Library/Application Support/Code/User"
    if [ -d "$DOTFILES_DIR/.vscode" ]; then
        echo ""
        echo "🖥️ Linking Visual Studio Code settings (macOS)..."
        link_file "$DOTFILES_DIR/.vscode/settings.json"    "$VSCODE_USER_DIR/settings.json"
        link_file "$DOTFILES_DIR/.vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
    fi
fi

echo ""
echo "✅ Dotfiles setup complete!"
