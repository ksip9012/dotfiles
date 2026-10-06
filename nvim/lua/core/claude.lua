-- --- Claude Code 連携 ---
-- 起動ディレクトリごとに固定のソケットで待ち受け、Claude Code の hook
-- (claude/hooks/open-in-nvim.sh) から編集したファイルを開けるようにする。
-- ソケットパスの算出方法は hook 側と揃えること。

local M = {}

local function socket_path(dir)
  local real = vim.uv.fs_realpath(dir) or dir
  local hash = vim.fn.sha256(real):sub(1, 12)
  return vim.fn.stdpath('state') .. '/claude/' .. hash .. '.sock'
end

-- 同じディレクトリで別の nvim がすでに待ち受けていれば何もしない
local function in_use(path)
  local ok, chan = pcall(vim.fn.sockconnect, 'pipe', path, { rpc = true })
  if ok and chan > 0 then
    vim.fn.chanclose(chan)
    return true
  end
  return false
end

function M.setup()
  local path = socket_path(vim.fn.getcwd())
  if vim.uv.fs_stat(path) then
    if in_use(path) then return end
    os.remove(path) -- 前回異常終了したときの残骸
  end
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  pcall(vim.fn.serverstart, path)
end

-- hook から `v:lua.require'core.claude'.open(path)` で呼ばれる
function M.open(path)
  local ok, err = pcall(vim.cmd.drop, vim.fn.fnameescape(path))
  if not ok then
    vim.notify('Claude: ' .. err, vim.log.levels.WARN)
    return ''
  end
  vim.cmd.checktime()
  return ''
end

return M
