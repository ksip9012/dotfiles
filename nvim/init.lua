-- Leader key
vim.g.mapleader = ' '

-- nvim-tree: netrw を無効化（競合防止のため plugins より前に設定）
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- Core settings
require('core.options')
require('core.keymaps')

-- Plugins
require('plugins')

-- LSP (Neovim 0.11+)
require('lsp').setup()

-- UI/Theme Customization
require('theme.highlights').setup()
