# fzf 初期化
eval "$(fzf --zsh)"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_GREP_COMMAND='rg --column --line-number --no-heading --color=always --smart-case'
export FZF_DEFAULT_OPTS='
  --height 40% --layout=reverse --border
  --bind "ctrl-/:toggle-preview"
'

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {}'"
