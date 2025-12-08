# コマンド入力と補完の改善設定

# 補完候補をコンパクトに表示して、画面の情報量を最適化
setopt list_packed
# コマンドのスペルミスを訂正
setopt correct
# ディレクトリ名の補完時に末尾にスラッシュを自動追加
setopt auto_param_slash
# ディレクトリ名を強調表示
setopt mark_dirs
# パラメータ展開時のキー操作を自動化
setopt auto_param_keys
# 拡張 glob の有効化
setopt extended_glob
# cd コマンドを省略
setopt auto_cd
# 履歴ファイル（.zsh_history）の場所と最大行数を設定
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000  # ターミナルセッションメモリ内の履歴最大数
SAVEHIST=100000  # 履歴ファイルに保存する最大行数

# 履歴の共有
setopt share_history # 複数のシェルで履歴を共有

# 重複した履歴の削除と記録
setopt hist_ignore_all_dups # コマンド実行前に重複を削除
setopt hist_save_no_dups    # ファイルに書き込むときに直前の重複を除外