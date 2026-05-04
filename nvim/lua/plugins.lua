-- lazy.nvim のブートストラップ
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { 'folke/tokyonight.nvim', priority = 1000, lazy = false },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {'nvim-tree/nvim-web-devicons'},
    config = function()
      require('nvim-tree').setup({
        update_focused_file = { enable = true },
        git = { enable = true, ignore = false },
        renderer = {
          indent_markers = { enable = true },
        },
      })

      local function hide_cursor()
        local cursorline_hl = vim.api.nvim_get_hl(0, { name = 'CursorLine', link = false })
        local normal_hl     = vim.api.nvim_get_hl(0, { name = 'Normal',     link = false })
        local hl_options = {}
        if cursorline_hl.bg then hl_options.bg = cursorline_hl.bg end
        if normal_hl.fg     then hl_options.fg = normal_hl.fg     end
        if next(hl_options) == nil then return end

        vim.api.nvim_set_hl(0, 'NvimTreeCursorInvisible', hl_options)
        local parts = {}
        for setting in string.gmatch(vim.api.nvim_get_option_value('guicursor', { scope = 'global' }), '[^,]+') do
          local mode_prefix, _ = setting:match('^([%w%-]+):(.+)$')
          if mode_prefix and mode_prefix:find('n') then
            table.insert(parts, mode_prefix .. ':ver01-NvimTreeCursorInvisible')
          else
            table.insert(parts, setting)
          end
        end
        vim.api.nvim_set_option_value('guicursor', table.concat(parts, ','), { scope = 'local' })
      end

      local function show_cursor()
        vim.api.nvim_set_option_value(
          'guicursor',
          vim.api.nvim_get_option_value('guicursor', { scope = 'global' }),
          { scope = 'local' }
        )
      end

      local group = vim.api.nvim_create_augroup('NvimTreeCursor', { clear = true })
      vim.api.nvim_create_autocmd('BufEnter', {
        group = group, pattern = 'NvimTree_*', callback = hide_cursor,
      })
      vim.api.nvim_create_autocmd('BufLeave', {
        group = group, pattern = 'NvimTree_*', callback = show_cursor,
      })
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function()
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = { 'node_modules', '.git/' },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
    end,
  },

  -- Git
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = require('gitsigns')
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = 'Git: ' .. desc })
          end
          -- ハンク単位の操作
          map('n', '<leader>hs', gs.stage_hunk,        'Stage hunk')
          map('n', '<leader>hr', gs.reset_hunk,        'Reset hunk')
          map('n', '<leader>hu', gs.undo_stage_hunk,   'Undo stage hunk')
          map('n', '<leader>hd', gs.diffthis,          'Diff this')
          map('n', '<leader>hb', gs.blame_line,        'Blame line')
          -- ハンク間の移動
          map('n', ']h', gs.next_hunk, 'Next hunk')
          map('n', '[h', gs.prev_hunk, 'Prev hunk')
        end,
      })
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    config = function()
      local p = require('theme.palette')
      local theme = {
        normal   = { a = { fg = p.base00, bg = p.base0D, gui = 'bold' }, b = { fg = p.base05, bg = p.base02 }, c = { fg = p.base04, bg = p.base01 } },
        insert   = { a = { fg = p.base00, bg = p.base0B, gui = 'bold' }, b = { fg = p.base05, bg = p.base02 }, c = { fg = p.base04, bg = p.base01 } },
        visual   = { a = { fg = p.base00, bg = p.base0E, gui = 'bold' }, b = { fg = p.base05, bg = p.base02 }, c = { fg = p.base04, bg = p.base01 } },
        replace  = { a = { fg = p.base00, bg = p.base08, gui = 'bold' }, b = { fg = p.base05, bg = p.base02 }, c = { fg = p.base04, bg = p.base01 } },
        command  = { a = { fg = p.base00, bg = p.base0A, gui = 'bold' }, b = { fg = p.base05, bg = p.base02 }, c = { fg = p.base04, bg = p.base01 } },
        inactive = { a = { fg = p.base04, bg = p.base01 },               b = { fg = p.base04, bg = p.base01 }, c = { fg = p.base04, bg = p.base01 } },
      }
      require('lualine').setup({ options = { theme = theme } })
    end,
  },

  -- Mason (サーバーのインストール管理のみ)
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = function()
      require('mason').setup()
    end,
  },

  -- 補完
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path', 'L3MON4D3/LuaSnip' },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>']      = cmp.mapping.confirm({ select = true }),
          ['<Tab>']     = cmp.mapping.select_next_item(),
          ['<S-Tab>']   = cmp.mapping.select_prev_item(),
          ['<C-d>']     = cmp.mapping.scroll_docs(4),
          ['<C-u>']     = cmp.mapping.scroll_docs(-4),
        }),
        sources = { {name = 'nvim_lsp'}, {name = 'buffer'}, {name = 'path'} },
      })
    end,
  },

  { 'windwp/nvim-autopairs', event = 'InsertEnter', config = function() require('nvim-autopairs').setup() end },

  -- フォーマッタ (Python は Ruff LSP が担当するため除外)
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          lua        = { 'stylua' },
          markdown   = { 'prettier' },
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          json       = { 'prettier' },
          yaml       = { 'prettier' },
          html       = { 'prettier' },
          css        = { 'prettier' },
        },
        format_on_save = {
          timeout_ms   = 500,
          lsp_fallback = false,
        },
      })
    end,
  },

  -- lazygit
  {
    'kdheepak/lazygit.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'LazyGit', 'LazyGitCurrentFile' },
  },

  -- インデントガイド
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      require('ibl').setup({
        indent = { char = '│' },
        scope  = { enabled = true },
      })
    end,
  },

  -- キーバインドヘルパー
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup()
    end,
  },
})
