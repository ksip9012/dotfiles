local M = {}

function M.setup()
  vim.cmd.colorscheme('tokyonight')
  local p = require("theme.palette")

  local function set_hl(group, val)
    val.force = true
    vim.api.nvim_set_hl(0, group, val)
  end

  -- --- 基本 (Syntax) ---
  set_hl('Normal', { fg = p.base05, bg = p.base00 })
  set_hl('Comment', { fg = p.base03, italic = true })
  set_hl('String', { fg = p.base0B })
  set_hl('Function', { fg = p.base0D, bold = true })
  set_hl('Keyword', { fg = p.base0E })
  set_hl('Type', { fg = p.base0A })
  set_hl('Constant', { fg = p.base09 })
  set_hl('Number', { fg = p.base09 })

  -- --- LSP Semantic Tokens (Treesitter 代替) ---
  set_hl('@lsp.type.class', { fg = p.base0A, bold = true })
  set_hl('@lsp.type.type', { fg = p.base0A })
  set_hl('@lsp.type.enum', { fg = p.base0A })
  set_hl('@lsp.type.interface', { fg = p.base0A })
  set_hl('@lsp.type.function', { fg = p.base0D, bold = true })
  set_hl('@lsp.type.method', { fg = p.base0D, bold = true })
  set_hl('@lsp.type.variable', { fg = p.base05 })
  set_hl('@lsp.type.property', { fg = p.base0C })
  set_hl('@lsp.type.parameter', { fg = p.base09, italic = true })
  set_hl('@lsp.type.number', { fg = p.base09 })
  set_hl('@lsp.type.decorator', { fg = p.base0F })
  set_hl('@lsp.type.namespace', { fg = p.base0E })
  set_hl('@lsp.type.builtinType', { fg = p.base0A })
  set_hl('@lsp.type.selfParameter', { fg = p.base08, italic = true })

  -- 優先度 (標準 Syntax よりも LSP を優先)
  vim.highlight.priorities.semantic_tokens = 200
end

return M
