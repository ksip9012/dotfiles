-- Leader key
vim.g.mapleader = ' '

-- Core settings
require('core.options')
require('core.keymaps')

-- Plugins
require('plugins')

-- LSP (Neovim 0.11+)
require('lsp').setup()

-- UI/Theme Customization
require('theme.highlights').setup()
