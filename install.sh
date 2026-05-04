#!/bin/bash
#
# install.sh
# This script creates symlinks from the home directory to the dotfiles in this repository.

# Get the absolute path to the dotfiles directory, which is the directory of this script.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR=$HOME
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"

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

# --- Helper function for verifying symlinks ---
# $1: expected symlink path
# $2: expected target path
verify_link() {
    local link_path="$1"
    local expected_target="$2"

    if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$expected_target" ]; then
        echo "  ✅ $link_path"
    else
        echo "  ❌ $link_path (期待: $expected_target → 実際: $(readlink "$link_path" 2>/dev/null || echo 'リンクなし'))"
    fi
}

# --- Homebrew Setup ---
if command -v brew >/dev/null 2>&1; then
    if [ -f "$DOTFILES_DIR/Brewfile" ]; then
        mkdir -p "$CACHE_DIR"
        BREWFILE_HASH_CACHE="$CACHE_DIR/brewfile.sha256"
        CURRENT_HASH=$(shasum -a 256 "$DOTFILES_DIR/Brewfile" | awk '{print $1}')

        if [ "$(cat "$BREWFILE_HASH_CACHE" 2>/dev/null)" != "$CURRENT_HASH" ]; then
            echo "📦 Installing Homebrew packages via Brewfile..."
            brew bundle --file="$DOTFILES_DIR/Brewfile"
            echo "$CURRENT_HASH" > "$BREWFILE_HASH_CACHE"
        else
            echo "📦 Brewfile unchanged, skipping brew bundle."
        fi
    fi
else
    echo "⚠️ Homebrew not found. Skipping package installation."
fi

# --- Palette generation ---
echo ""
echo "🎨 Generating palette files from theme/palette.lua..."
if command -v python3 >/dev/null 2>&1; then
    python3 "$DOTFILES_DIR/theme/generate.py"
else
    echo "⚠️ python3 not found. Skipping palette generation."
fi

# --- Link configuration files ---

echo ""
echo "🔗 Linking configuration files..."

# Zsh
link_file "$DOTFILES_DIR/zsh/.zshrc"              "$HOME_DIR/.zshrc"
link_file "$DOTFILES_DIR/zsh/.zsh.d"              "$HOME_DIR/.zsh.d"

# Git
link_file "$DOTFILES_DIR/git/.config/git/config"  "$HOME_DIR/.config/git/config"

# WezTerm (XDG: ~/.config/wezterm/wezterm.lua)
link_file "$DOTFILES_DIR/wezterm/wezterm.lua"       "$HOME_DIR/.config/wezterm/wezterm.lua"

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
link_file "$DOTFILES_DIR/claude/skills"            "$HOME_DIR/.claude/skills"

# --- Git local config setup ---
GIT_LOCAL="$HOME_DIR/.config/git/local"
GIT_LOCAL_EXAMPLE="$DOTFILES_DIR/git/.config/git/local.example"

if [ ! -f "$GIT_LOCAL" ]; then
    echo ""
    echo "👤 Git のユーザー情報を設定します（~/.config/git/local を作成）..."
    printf "  名前  (git user.name) : "
    read -r git_name
    printf "  メール (git user.email): "
    read -r git_email

    mkdir -p "$(dirname "$GIT_LOCAL")"
    sed -e "s/Your Name/$git_name/" \
        -e "s/your@email.com/$git_email/" \
        "$GIT_LOCAL_EXAMPLE" > "$GIT_LOCAL"
    echo "  ✅ ~/.config/git/local を作成しました。"
else
    echo ""
    echo "👤 ~/.config/git/local はすでに存在します。スキップします。"
fi

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

# --- Verify symlinks ---
echo ""
echo "🔍 Verifying symlinks..."
verify_link "$HOME_DIR/.zshrc"                    "$DOTFILES_DIR/zsh/.zshrc"
verify_link "$HOME_DIR/.zsh.d"                    "$DOTFILES_DIR/zsh/.zsh.d"
verify_link "$HOME_DIR/.config/git/config"        "$DOTFILES_DIR/git/.config/git/config"
verify_link "$HOME_DIR/.config/wezterm/wezterm.lua" "$DOTFILES_DIR/wezterm/wezterm.lua"
verify_link "$HOME_DIR/.config/starship.toml"     "$DOTFILES_DIR/starship/.starship.toml"
verify_link "$HOME_DIR/.config/mise"              "$DOTFILES_DIR/mise"
verify_link "$HOME_DIR/.config/sheldon"           "$DOTFILES_DIR/sheldon"
verify_link "$HOME_DIR/.config/nvim"              "$DOTFILES_DIR/nvim"
verify_link "$HOME_DIR/.config/aerospace"         "$DOTFILES_DIR/aerospace"
verify_link "$HOME_DIR/.newsboat"                 "$DOTFILES_DIR/newsboat"
verify_link "$HOME_DIR/.claude/settings.json"     "$DOTFILES_DIR/claude/settings.json"
verify_link "$HOME_DIR/.claude/CLAUDE.md"         "$DOTFILES_DIR/claude/CLAUDE.md"
verify_link "$HOME_DIR/.claude/skills"            "$DOTFILES_DIR/claude/skills"

echo ""
echo "✅ Dotfiles setup complete!"
