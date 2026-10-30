# エイリアス

# Homebrew

function _brew() {
  # ログファイルの設定
  local log_dir="${XDG_CACHE_HOME:-$HOME/.cache}/Homebrew/Logs"
  mkdir -p "$log_dir"

  local date_str=$(date +%Y%m%d_%H%M%S)
  local log_file="$log_dir/brew_${date_str}.log"
  # curl の失敗記録（~/.config/homebrew/curlrc の write-out が追記する）
  local curl_log="$log_dir/curl_errors.log"

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
  __brew_run_step() {
    echo -e "\n${blue}==> $1...${reset}"
    local curl_lines_before=$(wc -l 2>/dev/null < "$curl_log" || echo 0)
    local step_status=0
    eval "$2" 2>&1 | tee -a "$log_file" || step_status=1
    __brew_record_curl_errors "$2" "$curl_lines_before"
    if (( step_status != 0 )); then
      echo -e "${red}[!] $1 でエラーが発生しましたが、続行します。${reset}"
    fi
  }

  # このステップ中に curl が記録した失敗行の前に、時刻とコマンドの見出しを挿入する
  __brew_record_curl_errors() {
    local before=$2
    local after=$(wc -l 2>/dev/null < "$curl_log" || echo 0)
    (( after > before )) || return 0
    local header="=== $(date '+%Y-%m-%d %H:%M:%S') $1 ==="
    awk -v n="$before" -v h="$header" 'NR == n + 1 { print h } 1' "$curl_log" > "$curl_log.tmp" \
      && mv "$curl_log.tmp" "$curl_log"
    echo -e "${yellow}[!] curl のダウンロード失敗が $((after - before)) 件ありました（Homebrew が再試行済みの場合もあります）: $curl_log${reset}" \
      | tee -a "$log_file"
  }

  # 1. Homebrew 本体とグローバルツールの更新
  # これにより git, docker, mise(本体), uv(本体) などが最新になります
  __brew_run_step "Homebrew 定義の更新" "brew update"
  __brew_run_step "グローバルツールのアップグレード" "brew upgrade"
  __brew_run_step "アプリ(Cask)の更新" "brew upgrade --cask --greedy"

  # 2. 徹底的な掃除
  # 不要な依存関係(lib...)と古いキャッシュを削除してディスクを空けます
  __brew_run_step "不要な依存関係の自動削除" "brew autoremove"
  __brew_run_step "古いキャッシュとバージョンの削除" "brew cleanup"

  # 3. 状態の保存と健康診断
  # 最後に doctor を行うことで、今の構成に不備がないか確認します
  __brew_run_step "システム診断" "brew doctor"
  __brew_run_step "Brewfile の更新" "brew bundle dump --file=\"$HOME/.dotfiles/Brewfile\" --force"

  # 4. 30日以上前のログファイルを削除
  find "$log_dir" -name "brew_*.log" -type f -mtime +30 -delete
  echo "過去30日以上前のファイルを削除しました。"

  # 5. 完了報告
  local end_time=$(date +%s)
  local elapsed=$((end_time - start_time))


  echo -e "\n${green}--- ✅ 基盤メンテナンス完了！ (${elapsed}秒) ---${reset}"
  echo -e "${blue}現在: $(brew list --formula | wc -l) Formulae, $(brew list --cask | wc -l) Casks${reset}"

  # Cask の更新でキャッシュされた sudo 認証を破棄
  sudo -k
}
alias mbrew="_brew"

# VS code

function _gtd() {
  cd ~/Documents/life
  code .
}
alias gtd="_gtd"

# eza
alias ll='eza -la --icons --git --time-style=relative'
alias lt='eza --tree --icons --level=2'

# 標準コマンドの上書きは人間の操作時のみ（Claude Code は CLAUDECODE=1 を設定する）
if [[ -z "$CLAUDECODE" ]]; then
  alias cat='bat --paging=never'
  alias ls='eza --icons --git'

  # modern CLI replacements
  alias grep='rg'
  alias rm='rip'
fi

# WezTerm: 現在のタブの自ペイン以外をすべて閉じる
function devclose() {
  local current=$WEZTERM_PANE
  wezterm cli list --format json \
    | jq -r --argjson cur "$current" '
        (map(select(.pane_id == $cur)) | .[0].tab_id) as $tab |
        .[] | select(.tab_id == $tab and .pane_id != $cur) | .pane_id
      ' \
    | while read -r pane_id; do
        wezterm cli kill-pane --pane-id "$pane_id"
      done
}

# WezTerm: カレントディレクトリで 3 ペインレイアウト展開（左上: claude / 右: nvim / 左下: terminal）
function dev() {
  local left_pane=$WEZTERM_PANE
  local cwd="${1:-$PWD}"

  # 右に 60% で分割 → nvim
  local right_pane
  right_pane=$(wezterm cli split-pane --right --percent 60 --cwd "$cwd")

  # 左ペインを下に 50% で分割 → terminal（フォーカス先）
  local bottom_pane
  bottom_pane=$(wezterm cli split-pane --bottom --percent 50 --pane-id "$left_pane" --cwd "$cwd")

  # 各ペインにコマンドを送信
  wezterm cli send-text --pane-id "$left_pane" --no-paste $'claude\n'
  wezterm cli send-text --pane-id "$right_pane" --no-paste $'nvim\n'

  # フォーカスを左下のターミナルに
  wezterm cli activate-pane --pane-id "$bottom_pane"
}
