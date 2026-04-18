local map = vim.keymap.set

-- ファイラー
map('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', {desc = 'Toggle file tree'})

-- Telescope
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>', {desc = 'Find files'})
map('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', {desc = 'Live grep'})
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>', {desc = 'Buffers'})
map('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>', {desc = 'Recent files'})

-- Git (lazygit)
map('n', '<leader>gg', '<cmd>LazyGit<CR>', {desc = 'LazyGit'})

-- ペイン移動 (Ctrl+hjkl)
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- 保存・終了
map('n', '<leader>w', ':w<CR>', {desc = 'Save'})
map('n', '<leader>q', ':q<CR>', {desc = 'Quit'})

-- 診断情報
map('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>', {desc = 'Show diagnostics'})
map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', {desc = 'Prev diagnostic'})
map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', {desc = 'Next diagnostic'})

-- which-key グループラベル
local ok, wk = pcall(require, 'which-key')
if ok then
  wk.add({
    { '<leader>h', group = 'Git hunk' },
    { '<leader>f', group = 'Telescope' },
    { '<leader>g', group = 'Git' },
  })
end