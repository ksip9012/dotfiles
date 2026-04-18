-- --- 基本設定 (vim.opt) ---
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 50
vim.opt.cursorline = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.undofile = true

-- マウス有効化
vim.opt.mouse = 'a'

-- 検索時に大文字小文字を賢く扱う
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- クリップボード (pbcopy/pbpaste 連携)
vim.g.clipboard = {
  name = 'pbcopy',
  copy = { ['+'] = 'pbcopy', ['*'] = 'pbcopy' },
  paste = { ['+'] = 'pbpaste', ['*'] = 'pbpaste' },
  cache_enabled = 0,
}
vim.opt.clipboard = 'unnamedplus'

-- 標準 syntax の有効化
vim.cmd("syntax enable")

-- --- 空白・不可視文字の表示設定 (VSCode 風) ---
vim.opt.list = true
vim.opt.listchars = {
  tab = '» ',       -- タブを » で表示
  trail = '·',      -- 行末の空白を · で表示
  nbsp = '␣',       -- 改行なしスペースを表示
  -- space = '·',   -- すべてのスペースを表示したい場合は有効化（少しうるさくなるので、まずは行末のみがおすすめ）
}

-- --- 便利機能 (Autocmd) ---

-- Python: PEP 8 の文字数ガイドライン (72: docstring、79: コード)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.opt_local.colorcolumn = '72,79'
  end,
})

-- 1. ファイル保存時に末尾の空白を削除する
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

-- 2. ヤンク（コピー）した箇所を一瞬光らせる
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({
      higroup = 'Visual',
      timeout = 150,
    })
  end,
})
