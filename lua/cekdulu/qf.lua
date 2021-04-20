local config = require("cekdulu.config")
local loaddata = require("cekdulu.load-data")
local windows = require("cekdulu.windows")
local util = require("cekdulu.utils")

local fn = vim.fn
local api = vim.api

local index = nil
local insert_note = false
-- local last_idx = 1

local M = {}

M = {
  user_lists = {},
  nonuser_lists = {},
}

local function is_qf_window()

  local filetype = api.nvim_buf_get_option(0, "filetype")

  if filetype ~= "qf" then
    print("[!] Current window not in the quickfix window..")
    return false
  end

  return true

end

local function get_current_title_qf()

  return fn.getqflist({ ["title"] = 1 }).title
end

local function is_qf_cekdulu()

  if not is_qf_window() then
    return
  end

  local what_title_qf = get_current_title_qf()

  if what_title_qf ~= config.bufnr_qf_bufname then
    print("[!] The item qf you pick thats not part of cekdulu_qf, continue..")
    return false
  end

  return true

end

-- local function del_tbl_idx_key(table)

--   for i = 1, #table do
--     if i == index then
--       table[i] = nil
--     end
--   end

-- end

-- local function insert_table(newtable, insert)

--   for i = 1, #insert do
--     table.insert(newtable, insert[i])
--   end

-- end

M.win_float_qf = function(contents)

  windows.reset_window()

  if not insert_note then
    config.relative = "win"
    config.enter = false
    config.row = config.row - 15
    config.col = config.col + 50

    windows.create_win_float_with_border(config, contents, function(_, win)
      config.bufnr_qf_winid = win

    end)
    return
  end

  insert_note = false

  config.relative = "editor"
  config.enter = true
  -- config.row = config.row - 1
  -- config.col = config.col - 1
  -- config.width = config.win_width - 15
  -- config.height = config.win_height - 15

  contents = contents or { "hore bro" }

  windows.create_win_float_with_border(config, contents, function(_, win)
    config.bufnr_note_winid = win

  end)

end

M.show_note_popup_close = function(bufnr)

  windows.close(bufnr)

end

M.show_note_popup = function(force)

  if force then
    return
  end

  if not is_qf_cekdulu() then
    return
  end

  index = fn.line(".")

  if index > #M.user_lists then
    return
  end

  if #M.user_lists[index].note > 0 then
    M.win_float_qf(M.user_lists[index].note)
  end

end

--------------------------------------
--------------------------------------

M.add = function()

  local get_curpos = fn.getcurpos()
  local get_line = fn.getline(".")

  local filename = fn.expand("%:p")

  local test = {
    bufnr = get_curpos[1],
    lnum = get_curpos[2],
    col = get_curpos[3],
    filename = filename,
    note = {},
    date = fn.strftime("%d %b %Y"),
    text = get_line,
  }

  table.insert(M.user_lists, test)

  M.update(M.user_lists)

end

-- TODO:
-- masih error saat add_note, selalu muncul buffer [Scratch] (cek command :ls!)
-- ada 3 cara yang terpikirkan untuk memecahkan masalah ini:
-- - masalahnya pada autocmds bufmove cursor, karena ketika berada di qf
-- dia aktif (close note dan open note)..namun ketika kita open edit note
-- dia menjadi aktif..makanya spawn bersamaan dengan open edit note
M.add_note = function()

  local filetype = api.nvim_buf_get_option(0, "filetype")

  if filetype ~= config.bufname then

    index = fn.line(".")

    local contents = #M.user_lists[index].note > 0
      and { "" }
      or M.user_lists[index].note

    insert_note = true

    M.win_float_qf(contents)
    return

  end

  --   if not api.nvim_buf_get_var(0, "floatwin_cekdulu_qf_note") == 1 then
  --     return
  --   end

  --   -- TODO: tutup buffer note yang masih terbuka di karenakan effect dari
  --   -- autocmd bufmoved
  --   M.show_note_popup_close(config.border_qf_border_winid)

  --   -- grab all content current buffer
  local stripped = vim.fn.getline(1, "$")

  if #stripped[1] > 0 then
    M.user_lists[index].note = stripped
  end

  api.nvim_command("wincmd p")

end

M.update = function(tbl, title)

  local action = "r"
  local tryidx = "$"

  local title_ctx = title or config.bufnr_qf_bufname

  local what = {
    title = title_ctx,
    context = title_ctx,
    items = tbl,
    idx = tryidx,
  -- quickfixtextfunc = "",
  }

  -- fn.setqflist({test}, "r")
  fn.setqflist({}, action, what)

end

M.save = function()

  -- local force = force_to_save or false

  -- if not is_qf_window() and force then
  --   return
  -- end

  if config.path_qf == nil then
    print(
      "[!] Cannot save qf lists! your path is empty/not exists. "
        .. "try to run :CekduluToggle first"
    )
    return
  end

  if #M.user_lists > 0 then
    local data = fn.json_encode(M.user_lists)
    fn.writefile({ data }, config.path_qf)
    return
  end

  print("[!] Nothing to save.., or check your file dest")

end

M.load = function()

  if not loaddata.check_filereadble(config.path_qf) then
    print("[!] your file not been set, run toggle first")
    return
  end

  local dest_check = fn.readfile(config.path_qf)

  if #dest_check <= 0 then
    print("[!] Path to load path_qf is empty, continue..")
    return
  end

  local datatable = fn.json_decode(dest_check)

  -- Tiap table `datatable` dari json_decode, itu berisi item table
  -- jadi kita mesti di loop lalu di masukkan ke M.user_lists
  for i = 1, #datatable do
    table.insert(M.user_lists, datatable[i])
  end

  M.update(M.user_lists)

  vim.cmd("copen")

end

M.yo = function()

  index = fn.line(".")

  print(M.user_lists[index].date)

end

M.remove = function()

  if not is_qf_window() then
    return
  end

  local what_title_qf = get_current_title_qf()

  local qfall = fn.getqflist()
  index = fn.line(".")

  local newtbl = {}

  for i = 1, #qfall do
    if i == index then
      qfall[i] = nil
    end

    table.insert(newtbl, qfall[i])
  end

  local what = {
    title = what_title_qf,
    context = what_title_qf,
    items = newtbl,
    idx = "$",
  -- quickfixtextfunc = "",
  }
  if what_title_qf == config.bufnr_qf_bufname then
    M.user_lists = newtbl
    M.update(M.user_lists)
  else
    fn.setqflist({}, "r", what)
  end

end

M.buf_move_cursor = function()

  -- if not is_qf_window() and win_qfnote_active == 1 then
  --   return
  -- end

  -- local filetype = api.nvim_buf_get_option(0, "filetype")
  insert_note = false

  M.buf_leave()
  -- print("move cursor bergerak ", config.bufnr_qf_winid)

  M.show_note_popup()

end

M.buf_enter = function()

  insert_note = false

  M.show_note_popup(true)

end

M.buf_leave = function()

  insert_note = false

  M.show_note_popup_close(config.bufnr_qf_winid)
  M.show_note_popup_close(config.bufnr_note_winid)

end

M.enable = function()

  if not is_qf_window() then
    return
  end

  local what_title_qf = get_current_title_qf()

  -- eww ugly creating autocmds with string..!
  if what_title_qf == config.bufnr_qf_bufname then

    api.nvim_exec(
      [[
          augroup Cekdulu_qf
              autocmd! BufLeave,WinLeave,CursorMoved,TabEnter,BufHidden,VimResized <buffer>
              autocmd! BufEnter,QuitPre <buffer>
              autocmd CursorMoved <buffer> lua require'cekdulu.qf'.buf_move_cursor()
              autocmd BufEnter <buffer> lua require'cekdulu.qf'.buf_enter()
              autocmd BufLeave <buffer> lua require'cekdulu.qf'.buf_leave()
          augroup END
      ]],

      false
    )

  end

end

--------------------------------------
--------------------------------------

M.qf_fkeep = function(tmode)

  local pattern = tmode or ""

  if not is_qf_window() then
    return
  end

  local ans_keep = fn.input("Keep > ")

  if #ans_keep == 0 then
    return
  end

  local newtable = {}

  -- freject, me-reject file berdasarkan pattern nya
  if pattern == "freject" then

    util.clear_prompt()

    local getqf = fn.getqflist()

    for i = 1, #getqf do
      -- print(getqf[i])
      if
      -- TODO: regex belum optimal!!
        api.nvim_buf_get_name(getqf[i].bufnr):match("[/]*" .. ans_keep .. ".*")
      then
        table.insert(newtable, getqf[i])
      end
    end

  end

  local what = {
    title = ":setqflist() " .. "[" .. ans_keep .. "]",
    context = ":setqflist() " .. "[" .. ans_keep .. "]",
    items = newtable,
    idx = "$",
  }

  fn.setqflist({}, "r", what)

end

return M
