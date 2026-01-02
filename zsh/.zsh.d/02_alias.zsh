# エイリアス

# Homebrew

function _brew() {
  echo "--- 🍺 Homebrew 一括メンテナンス開始 ---"

  echo "==> 1. Homebrew Definitions (brew update)"
  brew update && \

  echo "==> 2. Formula Upgrades (brew upgrade)"
  brew upgrade && \

  echo "==> 3. Cask Upgrades (brew upgrade --cask)"
  brew upgrade --cask && \

  echo "==> 4. Cleanup old files (brew cleanup)"
  brew cleanup && \

  # パッケージの追加・削除が完了した後、現在の状態をBrewfileに上書きします
  echo "==> 5. Update Brewfile (brew bundle dump)"
  brew bundle dump --file="$HOME/.dotfiles/Brewfile" --force && \

  echo "==> 6. System Health Check (brew doctor)"
  brew doctor

  # 最後のコマンド（brew doctor）が成功したかどうかにかかわらず、完了メッセージを表示
  echo "--- ✅ Homebrew メンテナンス完了 ---"
}
alias mbrew="_brew"

# VS code

function _gtd() {
  cd ~/Documents/life
  code .
}
alias gtd="_gtd"

