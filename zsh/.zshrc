###########################################################
# 分割ファイルの読み込みセクション

# 読み込むディレクトリ指定
ZSH_DIR="${HOME}/.dotfiles/zsh/.zsh.d"
# それ以外のファイルを読み込む
if [ -d $ZSH_DIR ] && [ -r $ZSH_DIR ] && [ -x $ZSH_DIR ]; then
for file in ${ZSH_DIR}/*.zsh(N^s); do
    source "$file"
  done
fi
###########################################################
# compinit を実行する
autoload -Uz compinit && compinit -i
###########################################################
# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
###########################################################
# mise
eval "$(mise activate zsh)"
###########################################################
# sheldon
eval "$(sheldon source)"
###########################################################
# beep
setopt no_beep
setopt nolistbeep
###########################################################
# alias
alias ls="lsd -al"
###########################################################
# starship - put last part of .zshrc
eval "$(starship init zsh)"
