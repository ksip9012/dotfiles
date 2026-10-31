-- --- Claude Code 連携 ---
-- 起動ディレクトリごとに固定のソケットで待ち受け、Claude Code の hook
-- (claude/hooks/nvim-follow.sh) から Claude の作業を自動で追いかける。
-- ソケットパスの算出方法は hook 側と揃えること。
-- hook から呼ばれる関数はすぐ返し、実際の処理は vim.schedule で行う
-- （確認のプロンプトなどで hook、ひいては Claude Code を止めないため）。

local M = {}

local root        -- 待ち受けを始めたディレクトリ（Bash で変わったファイルを探す範囲）
local turn_start  -- 今のターンが始まった時刻

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

-- 未保存の変更がないファイルだけ読み込み直す（変更があると確認のプロンプトが出るため）
local function reload_unmodified()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == ''
        and not vim.bo[buf].modified and vim.api.nvim_buf_get_name(buf) ~= '' then
      vim.cmd.checktime(buf)
    end
  end
end

function M.setup()
  vim.o.autoread = true
  vim.api.nvim_create_autocmd('FocusGained', {
    group = vim.api.nvim_create_augroup('ClaudeReload', { clear = true }),
    callback = reload_unmodified,
  })

  root = vim.fn.getcwd()
  local path = socket_path(root)
  if vim.uv.fs_stat(path) then
    if in_use(path) then return end
    os.remove(path) -- 前回異常終了したときの残骸
  end
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  pcall(vim.fn.serverstart, path)
end

-- 書き込んだ文字列を含む最初の行
local function find_line(needle)
  for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:find(needle, 1, true) then return i end
  end
end

-- git の差分（未コミット → 直前のコミットの順）から、最初に変わった行
local function first_changed_line(path)
  local git = { 'git', '-C', vim.fs.dirname(path) }
  for _, args in ipairs({
    { 'diff', '-U0', 'HEAD', '--', path },
    { 'log', '-1', '-p', '-U0', '--format=', '--', path },
  }) do
    local res = vim.system(vim.list_extend(vim.list_extend({}, git), args), { text = true }):wait()
    local line = res.code == 0 and res.stdout:match('@@ %-[%d,]+ %+(%d+)')
    if line then return math.max(tonumber(line), 1) end
  end
end

-- 編集中なら邪魔をせず通知だけにする
local function busy(path)
  local buf = vim.fn.bufnr(path)
  return vim.bo.modified or vim.fn.mode() ~= 'n' or vim.fn.getcmdwintype() ~= ''
    or (buf ~= -1 and vim.bo[buf].modified)
end

-- path を開き、line（関数なら開いた後に呼んで求める）の行へ移動する
local function show(path, line, verb)
  if busy(path) then
    vim.notify('Claude: ' .. vim.fn.fnamemodify(path, ':~:.') .. ' を' .. verb .. 'ました')
    return
  end
  if vim.bo.filetype == 'NvimTree' then vim.cmd.wincmd('p') end
  local ok, err = pcall(vim.cmd.drop, vim.fn.fnameescape(path))
  if not ok then
    vim.notify('Claude: ' .. err, vim.log.levels.WARN)
    return
  end
  vim.cmd.checktime(vim.api.nvim_get_current_buf())
  if type(line) == 'function' then line = line() end
  if line then
    vim.api.nvim_win_set_cursor(0, { math.min(line, vim.api.nvim_buf_line_count(0)), 0 })
    vim.cmd('normal! zz')
  end
end

-- PostToolUse (Edit/Write) から呼ばれる
function M.open(path, needle)
  vim.schedule(function()
    show(path, function()
      return (needle and needle ~= '' and find_line(needle)) or first_changed_line(path)
    end, '変更し')
  end)
  return ''
end

-- PostToolUse (Read) から呼ばれる
function M.view(path, line)
  vim.schedule(function() show(path, line, '読み') end)
  return ''
end

-- UserPromptSubmit から呼ばれる
function M.mark()
  turn_start = os.time()
  return ''
end

-- Stop から呼ばれる。このターンに変わったファイルのうち最後のものを開く
-- （すでに表示中なら、Edit で移動した位置を保つため開き直さない）
function M.sync()
  vim.schedule(function()
    reload_unmodified()
    if not (turn_start and root) then return end
    local res = vim.system({ 'git', '-C', root, 'ls-files', '-co', '--exclude-standard' },
      { text = true }):wait()
    if res.code ~= 0 then return end
    local latest, latest_sec = nil, turn_start - 1
    for rel in res.stdout:gmatch('[^\n]+') do
      local path = root .. '/' .. rel
      local stat = vim.uv.fs_stat(path)
      if stat and stat.mtime.sec > latest_sec then
        latest, latest_sec = path, stat.mtime.sec
      end
    end
    turn_start = nil
    if latest and latest ~= vim.api.nvim_buf_get_name(0) then
      show(latest, function() return first_changed_line(latest) end, '変更し')
    end
  end)
  return ''
end

return M
