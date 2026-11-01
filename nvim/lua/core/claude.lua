-- --- Claude Code 連携 ---
-- 起動ディレクトリごとに固定のソケットで待ち受け、Claude Code の hook
-- (claude/hooks/nvim-follow.sh) から Claude の作業を自動で追いかける。
-- ソケットパスの算出方法は hook 側と揃えること。
-- hook から呼ばれる関数はすぐ返し、実際の処理は vim.schedule で行う
-- （確認のプロンプトなどで hook、ひいては Claude Code を止めないため）。

local M = {}

local root        -- 待ち受けを始めたディレクトリ（Bash で変わったファイルを探す範囲）
local turn_start  -- 今のターンが始まった時刻
local baselines = {} -- このターンで Claude が最初に編集する前の内容（パス → 行のリスト）

-- Claude がこのターンに変えた行の印（gitsigns より優先して出す）
local ns = vim.api.nvim_create_namespace('claude_changes')
local signs = {
  add    = { text = '┃', hl = 'ClaudeAdd' },
  change = { text = '┃', hl = 'ClaudeChange' },
  delete = { text = '▸', hl = 'ClaudeDelete' },
}

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

-- 編集前の内容: 開いているバッファ（まだ読み込み直していない）→ git の HEAD の順に探す。
-- git の管理下で HEAD にないファイルは新しく作ったものとして空にする
local function read_baseline(path)
  local buf = vim.fn.bufnr(path)
  if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) and not vim.bo[buf].modified then
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  end
  local git = { 'git', '-C', vim.fs.dirname(path) }
  local res = vim.system(vim.list_extend(vim.list_extend({}, git),
    { 'show', 'HEAD:./' .. vim.fs.basename(path) }), { text = true }):wait()
  if res.code == 0 then
    local lines = vim.split(res.stdout, '\n', { plain = true })
    if lines[#lines] == '' then table.remove(lines) end
    return lines
  end
  res = vim.system(vim.list_extend(vim.list_extend({}, git), { 'rev-parse' })):wait()
  if res.code == 0 then return {} end
end

local function as_text(lines)
  return #lines == 0 and '' or table.concat(lines, '\n') .. '\n'
end

-- 編集前の内容と今のバッファを比べて、変わった行に印を付け直す
local function mark_changes(path)
  local base = baselines[path]
  local buf = vim.fn.bufnr(path)
  if not base or buf == -1 or not vim.api.nvim_buf_is_loaded(buf) or vim.bo[buf].modified then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local hunks = vim.text.diff(as_text(base), as_text(lines), { result_type = 'indices' })
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local function put(lnum, sign)
    lnum = math.min(math.max(lnum, 1), #lines)
    vim.api.nvim_buf_set_extmark(buf, ns, lnum - 1, 0,
      { sign_text = sign.text, sign_hl_group = sign.hl, priority = 20 })
  end
  for _, h in ipairs(hunks) do
    local _, count_a, start_b, count_b = unpack(h)
    if count_b == 0 then
      put(start_b, signs.delete) -- 消した行のすぐ上の行
    else
      local sign = count_a == 0 and signs.add or signs.change
      for lnum = start_b, start_b + count_b - 1 do put(lnum, sign) end
    end
  end
end

function M.setup()
  vim.api.nvim_set_hl(0, 'ClaudeAdd', { link = 'Added', default = true })
  vim.api.nvim_set_hl(0, 'ClaudeChange', { link = 'Changed', default = true })
  vim.api.nvim_set_hl(0, 'ClaudeDelete', { link = 'Removed', default = true })
  vim.api.nvim_create_user_command('ClaudePin', function(opts) M.pin(opts.args) end,
    { nargs = '?', complete = 'file', desc = 'Claude: このウィンドウ（またはファイル）を左に固定する' })
  vim.api.nvim_create_user_command('ClaudeUnpin', function() M.unpin() end,
    { desc = 'Claude: 左の固定を外す' })
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

-- 左に固定したウィンドウ（:ClaudePin）。Claude が開くファイルはここを使わず、右の列に出す
local function pinned_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.w[win].claude_pinned then return win end
  end
end

-- ファイルを表示する、上から（同じ高さなら左から）順のウィンドウ（NvimTree や浮いているウィンドウは除く）
local function file_windows()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_win_get_config(win).relative == '' and vim.bo[buf].buftype == ''
        and vim.bo[buf].filetype ~= 'NvimTree' then
      table.insert(wins, win)
    end
  end
  table.sort(wins, function(a, b)
    local pa, pb = vim.api.nvim_win_get_position(a), vim.api.nvim_win_get_position(b)
    return pa[1] ~= pb[1] and pa[1] < pb[1] or (pa[1] == pb[1] and pa[2] < pb[2])
  end)
  return wins
end

-- 固定したウィンドウにいたら、右の列のウィンドウへ移る（なければ右に作る）
local function leave_pinned()
  local pin = pinned_window()
  if vim.api.nvim_get_current_win() ~= pin then return end
  for _, win in ipairs(file_windows()) do
    if win ~= pin then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.cmd('belowright vsplit')
end

-- path を開き、line（関数なら開いた後に呼んで求める）の行へ移動する
local function show(path, line, verb)
  if busy(path) then
    vim.notify('Claude: ' .. vim.fn.fnamemodify(path, ':~:.') .. ' を' .. verb .. 'ました')
    return
  end
  if vim.bo.filetype == 'NvimTree' then vim.cmd.wincmd('p') end
  if vim.fn.bufwinid(path) == -1 then leave_pinned() end
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
-- 編集前の内容は、読み込み直す前に取る必要があるので schedule の外で取る
function M.open(path, needle)
  if baselines[path] == nil then baselines[path] = read_baseline(path) or false end
  vim.schedule(function()
    show(path, function()
      return (needle and needle ~= '' and find_line(needle)) or first_changed_line(path)
    end, '変更し')
    mark_changes(path)
  end)
  return ''
end

-- PostToolUse (Read) から呼ばれる
-- 読んだだけのファイルで、このターンに編集したファイルの表示を押し出さない
-- （すでにどこかのウィンドウに出ていれば、そこへ移るだけなので開く）
function M.view(path, line)
  vim.schedule(function()
    local current = vim.api.nvim_buf_get_name(0)
    if vim.fn.bufwinnr(path) == -1 and baselines[current] then
      vim.notify('Claude: ' .. vim.fn.fnamemodify(path, ':~:.') .. ' を読みました')
      return
    end
    show(path, line, '読み')
  end)
  return ''
end

-- UserPromptSubmit から呼ばれる。前のターンの変更の印は消す
function M.mark()
  turn_start = os.time()
  baselines = {}
  vim.schedule(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
  end)
  return ''
end

-- 返答の終わりに並べるのは、人が読むファイルだけ（機械が読むデータは並べない）
local skip_ext = { jsonl = true, json = true, csv = true, tsv = true, lock = true, log = true }
local max_windows = 4

-- このターンに変わったファイル（Edit/Write したもの + Bash などで変わったもの）を、変わった順に
local function changed_files()
  local files = {}
  for path in pairs(baselines) do files[path] = true end
  local res = vim.system({ 'git', '-C', root, 'ls-files', '-co', '--exclude-standard' },
    { text = true }):wait()
  if res.code == 0 then
    for rel in res.stdout:gmatch('[^\n]+') do
      local stat = vim.uv.fs_stat(root .. '/' .. rel)
      if stat and stat.mtime.sec >= turn_start then files[root .. '/' .. rel] = true end
    end
  end
  local list = {}
  for path in pairs(files) do
    local ext = path:match('%.(%w+)$')
    local stat = vim.uv.fs_stat(path)
    if stat and stat.type == 'file' and not (ext and skip_ext[ext:lower()]) then
      table.insert(list, { path = path, mtime = stat.mtime.nsec + stat.mtime.sec * 1e9 })
    end
  end
  table.sort(list, function(a, b) return a.mtime < b.mtime end)
  local paths = {}
  for i = math.max(#list - max_windows + 1, 1), #list do table.insert(paths, list[i].path) end
  return paths, #list - #paths
end

-- ウィンドウを動かす前に NvimTree の幅を覚え、動かしたあと元の幅で左に戻す
local function find_tree()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'NvimTree' then
      return { win = win, width = vim.api.nvim_win_get_width(win) }
    end
  end
end

local function restore_tree(tree)
  if not (tree and vim.api.nvim_win_is_valid(tree.win)) then return end
  vim.api.nvim_win_call(tree.win, function() vim.cmd.wincmd('H') end)
  vim.api.nvim_win_set_width(tree.win, tree.width)
end

-- path の最初に変わった行へ win のカーソルを移す
local function jump_to_change(win, path)
  local line = first_changed_line(path)
  if not line then return end
  local count = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win))
  vim.api.nvim_win_set_cursor(win, { math.min(line, count), 0 })
  vim.api.nvim_win_call(win, function() vim.cmd('normal! zz') end)
end

-- ファイルのウィンドウを、今の順のまま上下に積み直す
local function stack()
  local wins = file_windows()
  local tree = find_tree()
  for i = #wins, 1, -1 do
    vim.api.nvim_win_call(wins[i], function() vim.cmd.wincmd('K') end)
  end
  restore_tree(tree)
end

-- 固定したウィンドウの右に 1列を作り、paths を上から順に積む。
-- 右にあったウィンドウは 1つに畳んでから分割し直す（hidden なのでバッファは残る）
local function fill_right(pin, paths, jump)
  local tree = find_tree()
  local rights = vim.tbl_filter(function(win) return win ~= pin end, file_windows())
  local col
  if #rights == 0 then
    vim.api.nvim_set_current_win(pin)
    vim.cmd('belowright vsplit')
    col = vim.api.nvim_get_current_win()
  else
    col = rights[1]
    for i = 2, #rights do pcall(vim.api.nvim_win_close, rights[i], false) end
    vim.api.nvim_win_call(col, function() vim.cmd.wincmd('L') end)
  end
  local wins = { col }
  for _ = 2, #paths do
    vim.api.nvim_set_current_win(wins[#wins])
    vim.cmd('belowright split')
    table.insert(wins, vim.api.nvim_get_current_win())
  end
  for i, path in ipairs(paths) do
    local win = wins[i]
    if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) ~= path then
      local ok = pcall(vim.api.nvim_win_call, win, function() vim.cmd.edit(vim.fn.fnameescape(path)) end)
      if ok and jump then jump_to_change(win, path) end
    end
    mark_changes(path)
  end
  restore_tree(tree)
  vim.cmd('wincmd =')
  vim.api.nvim_set_current_win(wins[#wins])
end

-- paths をすべてウィンドウに並べる。
-- 固定したウィンドウがあれば、そこに出ていないものを右の列に積む。
-- なければ、すでに表示中のものはそのまま残し、足りない分は関係のないファイルを出している
-- ウィンドウ（後ろから）を使い、なければ下に分割する。最後に上下に積み直す
local function arrange(paths)
  local pin = pinned_window()
  if pin then
    local pinned_name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(pin))
    local right = vim.tbl_filter(function(path) return path ~= pinned_name end, paths)
    if #right > 0 then fill_right(pin, right, true) end
    return
  end

  local wanted, shown, free = {}, {}, {}
  for _, path in ipairs(paths) do wanted[path] = true end
  for _, win in ipairs(file_windows()) do
    local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
    if wanted[name] and not shown[name] then
      shown[name] = win
    elseif not vim.bo[vim.api.nvim_win_get_buf(win)].modified then
      table.insert(free, win)
    end
  end
  -- 使うのは後ろのウィンドウから必要な数だけ。前から変わった順に入れる
  local needed = 0
  for _, path in ipairs(paths) do
    if not shown[path] then needed = needed + 1 end
  end
  free = vim.list_slice(free, math.max(#free - needed + 1, 1))
  local placed
  for _, path in ipairs(paths) do
    local win = shown[path]
    if not win then
      win = table.remove(free, 1)
      local ok
      if win then
        ok = pcall(vim.api.nvim_win_call, win, function() vim.cmd.edit(vim.fn.fnameescape(path)) end)
      else
        local wins = file_windows()
        if #wins > 0 then vim.api.nvim_set_current_win(wins[#wins]) end
        ok = pcall(vim.cmd, 'belowright split ' .. vim.fn.fnameescape(path))
        win = vim.api.nvim_get_current_win()
      end
      if ok then
        jump_to_change(win, path)
        mark_changes(path)
      end
    end
    placed = win
  end
  stack()
  vim.cmd('wincmd =')
  if placed and vim.api.nvim_win_is_valid(placed) then vim.api.nvim_set_current_win(placed) end
end

-- Stop から呼ばれる。このターンに変わったファイルをすべて並べる
-- （すでに表示中なら、Edit で移動した位置を保つため開き直さない）
function M.sync()
  vim.schedule(function()
    reload_unmodified()
    if not (turn_start and root) then return end
    local paths, hidden = changed_files()
    turn_start = nil
    if #paths == 0 then return end
    if vim.bo.modified or vim.fn.mode() ~= 'n' or vim.fn.getcmdwintype() ~= '' then
      vim.notify('Claude: ' .. #paths .. ' 個のファイルを変更しました')
      return
    end
    arrange(paths)
    if hidden > 0 then
      vim.notify('Claude: ほかに ' .. hidden .. ' 個のファイルを変更しました（並べきれないので省略）')
    end
  end)
  return ''
end

-- :ClaudePin [file] と Claude（remote-expr）から呼ばれる。
-- path（なければ今のウィンドウ）を左に固定し、ほかのウィンドウは右の 1列に積む
function M.pin(path)
  vim.schedule(function()
    if vim.bo.filetype == 'NvimTree' then vim.cmd.wincmd('p') end
    local win = vim.api.nvim_get_current_win()
    if path and path ~= '' then
      path = vim.fn.fnamemodify(path, ':p')
      local shown = vim.fn.bufwinid(path)
      if shown ~= -1 then
        win = shown
      else
        local ok, err = pcall(vim.cmd.edit, vim.fn.fnameescape(path))
        if not ok then
          vim.notify('Claude: ' .. err, vim.log.levels.WARN)
          return
        end
      end
    end
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do vim.w[w].claude_pinned = nil end
    vim.w[win].claude_pinned = true
    local tree = find_tree()
    vim.api.nvim_win_call(win, function() vim.cmd.wincmd('H') end)
    restore_tree(tree)
    local rights = {}
    for _, w in ipairs(file_windows()) do
      if w ~= win then table.insert(rights, vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))) end
    end
    if #rights > 0 then fill_right(win, rights, false) else vim.cmd('wincmd =') end
  end)
  return ''
end

function M.unpin()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do vim.w[w].claude_pinned = nil end
  return ''
end

return M
