local M = {}

-- LSP がアタッチされた際に行う共通設定 (キーマップなど)
local on_attach = function(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
  end

  -- 定義ジャンプ
  map('n', 'gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  -- ドキュメント表示 (ホバー)
  map('n', 'K', vim.lsp.buf.hover, 'Hover Documentation')
  -- 名前変更
  map('n', '<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  -- コードアクション (修正提案など)
  map('n', '<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  -- 参照の検索
  map('n', 'gr', vim.lsp.buf.references, '[G]oto [R]eferences')

  -- 保存時に Ruff でフォーマット（pyright との競合を防ぐため name を明示）
  if client.name == 'ruff' and client.server_capabilities.documentFormattingProvider then
    local group = vim.api.nvim_create_augroup('LspFormat_' .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr, async = false, name = 'ruff' })
      end,
    })
  end
end

function M.setup()
  -- Mason のバイナリを PATH に追加
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH

  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- --- Ruff (Python: リント・フォーマット) ---
  vim.lsp.config('ruff', {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', '.git', 'requirements.txt' },
    init_options = {
      settings = {
        lineLength = 79,
        showSyntaxErrors = true,
      },
    },
    capabilities = capabilities,
  })
  vim.lsp.enable('ruff')

  -- --- Pyright (Python: 補完・型チェック・定義ジャンプ) ---
  vim.lsp.config('pyright', {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', '.git', 'requirements.txt' },
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = 'openFilesOnly',
        },
      },
    },
    capabilities = capabilities,
  })
  vim.lsp.enable('pyright')

  -- --- LuaLS (Lua) ---
  vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
    settings = {
      Lua = {
        diagnostics = { globals = {'vim'} },
        workspace = { checkThirdParty = false },
      }
    },
    capabilities = capabilities,
  })
  vim.lsp.enable('lua_ls')

  -- LSP Attach 時に共通設定を適用
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, args.buf)
    end,
  })
end

return M
