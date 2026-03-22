-- ======================
-- 1. 基本設定の読み込み
-- ======================

-- リーダーキーを設定
vim.g.mapleader = ' '

-- core ディレクトリ内のファイルを読み込む
require('core.options')
require('core.keymaps')

-- =====================================
-- 2. プラグインマネージャのセットアップ
-- =====================================
require('plugins')


-- =======================
-- 3. カラースキームの適用
-- =======================
vim.cmd('colorscheme tokyonight')
vim.api.nvim_set_hl(0, 'Normal', {bg='none'})
vim.api.nvim_set_hl(0, 'NormalFloat', {bg='none'})

