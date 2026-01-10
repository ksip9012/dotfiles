# エイリアス

# Homebrew

function _brew() {
  # ログファイルの設定
  local log_dir="$HOME/.brew_logs"
  mkdir -p "$log_dir"

  local date_str=$(date +%Y%m%d_%H%M%S)
  local log_file="$log_dir/brew_${date_str}.log"

  local blue="\033[1;34m"
  local green="\033[1;32m"
  local yellow="\033[1;33m"
  local reset="\033[0m"
  local red="\033[1;31m"
  local start_time=$(date +%s)

  echo -e "${blue}--- 🍺 Homebrew 基盤メンテナンス開始 (プロジェクト設定は保護されます) ---${reset}"
  echo "詳細ログ: $log_file"

  # ログのヘッダー記録
  echo "=== Maintenance Start: $(date) ===" > "$log_file"

  # ヘルパー関数: 進捗の可視化
  run_step() {
    echo -e "\n${blue}==> $1...${reset}"
    if eval "$2" 2>&1 | tee -a "$log_file"; then
      return 0
    else
      echo -e "${red}[!] $1 でエラーが発生しましたが、続行します。${reset}"
    fi
  }

  # 1. Homebrew 本体とグローバルツールの更新
  # これにより git, docker, mise(本体), uv(本体) などが最新になります
  run_step "Homebrew 定義の更新" "brew update"
  run_step "グローバルツールのアップグレード" "brew upgrade"
  run_step "アプリ(Cask)の更新" "brew upgrade --cask --greedy"

  # 2. 徹底的な掃除
  # 不要な依存関係(lib...)と古いキャッシュを削除してディスクを空けます
  run_step "不要な依存関係の自動削除" "brew autoremove"
  run_step "古いキャッシュとバージョンの削除" "brew cleanup"

  # 3. 状態の保存と健康診断
  # 最後に doctor を行うことで、今の構成に不備がないか確認します
  run_step "システム診断" "brew doctor"
  run_step "Brewfile の更新" "brew bundle dump --file=\"$HOME/.dotfiles/Brewfile\" --force"

  # 4. 30日以上前の野ログファイルを削除
  find "$log_dir" -name "brew_*.log" -type f -mtime +30 -delete
  echo "過去30日以上前のファイルを削除しました。"

  # 5. 完了報告
  local end_time=$(date +%s)
  local elapsed=$((end_time - start_time))


  echo -e "\n${green}--- ✅ 基盤メンテナンス完了！ (${elapsed}秒) ---${reset}"
  echo -e "${blue}現在: $(brew list --formula | wc -l) Formulae, $(brew list --cask | wc -l) Casks${reset}"
}
alias mbrew="_brew"

# VS code

function _gtd() {
  cd ~/Documents/life
  code .
}
alias gtd="_gtd"

