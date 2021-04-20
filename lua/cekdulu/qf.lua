local config = require("cekdulu.config")
local loaddata = require("cekdulu.load-data")
local windows = require("cekdulu.windows")

local fn = vim.fn
local api = vim.api
-- local cmd = vim.cmd
-- local g = vim.get

local index = nil

local M = {}

M = {
  user_lists = {},
  nonuser_lists = {},

  title_qf = config.bufname_qf,
}

local function is_qf_window()

  local filetype = api.nvim_buf_get_option(0, "filetype")

  if filetype ~= "qf" then
    print("[!] Current window not in the quickfix window..")
    return false
  end

  return true

end

local function is_qf_cekdulu(title_qf)

  if not is_qf_window() then
    return
  end

  local title = title_qf or M.title_qf

  local what_title_qf = fn.getqflist({ ["title"] = 1 })

  if what_title_qf.title ~= title then
    print("[!] The item qf you pick thats not part of cekdulu_qf, continue..")
    return false
  end

  return true

end

local clear_prompt = function()
  api.nvim_command("normal :esc<CR>")
end

-- local clear_prompt_with_print = function()
--   clear_prompt()
--   print("aborting..")
--   return
-- end

local function deltable_by_key(table)

  for i = 1, #table do
    if i == index then
      table[i] = nil
    end
  end

end

local function table_insert(newtable, insert)

  for i = 1, #insert do
    table.insert(newtable, insert[i])
  end

end

M.win_float_qf = function(filetype, ask, contents)

  if windows.buf_exits(config.bufnr_qf, config.bufname_qf) then
    return
  end

  local data = ask or false

  local buf = windows.create_win_float(filetype, config, contents, function()

    if not data then

      if config.bufnr_qf_winid ~= nil then
        M.show_note_close(config.bufnr_qf_winid)
      end

      local buf = api.nvim_create_buf(false, true)
      api.nvim_buf_set_option(buf, "filetype", config.bufname_qf_note)
      api.nvim_buf_set_option(buf, "bufhidden", "wipe")
      api.nvim_buf_set_option(buf, "buftype", "nofile")

      local win = api.nvim_open_win(buf, true, config.bufnr_opts)
      -- M.create_border(buf_border, config)
      -- config.border_qf_border_winid = win

      api.nvim_buf_set_lines(buf, 0, -1, true, contents)
      api.nvim_win_set_option(
        win,
        "winhl",
        "Normal:Normal,EndOfBuffer:Normal"
      )

      api.nvim_buf_set_var(buf, "floatwin_cekdulu_qf_note", 1)
      api.nvim_set_current_win(win)

      vim.lsp.util.close_preview_autocmd({ "BufLeave" }, win)
      return win
    end
  end)

  config.border_qf_border_winid = buf

end

M.show_note_close = function(bufnr)

  windows.close(bufnr)

end

M.show_note_popup = function()

  if not is_qf_cekdulu() then
    return
  end

  index = fn.line(".")

  if index > #M.user_lists then
    return
  end

  if #M.user_lists[index].note > 0 then
    M.win_float_qf("qf", true, M.user_lists[index].note)
  end

end

M.move_cursor = function()

  if not is_qf_window() then
    return
  end

  local qf_winid = api.nvim_get_current_win()

  if qf_winid ~= config.bufnr_qf_winid and config.bufnr_qf_winid ~= nil then

    M.show_note_close(config.bufnr_qf_winid)

  end

  M.show_note_popup()

end

M.buf_enter = function()

  M.show_note_popup()

end

M.buf_leave = function()

  if config.bufnr_qf_winid ~= nil then
    M.show_note_close(config.bufnr_qf_winid)
  end

end

M.enable = function()

  if not is_qf_window() then
    return
  end

  local what_title_qf = fn.getqflist({ ["title"] = 1 })

  -- eww ugly creating autocmds with string..!
  if what_title_qf.title == M.title_qf then
    api.nvim_exec(
      [[
          augroup Cekdulu_qf
              autocmd! BufLeave,WinLeave,CursorMoved,TabEnter,BufHidden,VimResized <buffer>
              autocmd! BufEnter,QuitPre <buffer>
              autocmd CursorMoved <buffer> lua require'cekdulu.qf'.move_cursor()
          augroup END
      ]],

      false
    )

    -- autocmd BufLeave <buffer> lua require'cekdulu.qf'.buf_leave()
    -- autocmd BufEnter <buffer> lua require'cekdulu.qf'.buf_enter()
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
    date = {},
    text = get_line,
  }

  table.insert(M.user_lists, test)

  M.update(M.user_lists)

end

-- TODO:
-- - add note juga seharusnya berlaku juga diluar quickfix,
--   jadi sambil isi note langsung di masukkan ke quickfix berserta note nya.
--   jadi add_note harus punya kondisi dimana behavior nya berubah ketiak didalam
--  quickfix dan di liuar quickfix
--
-- FITUR: add_note ketika ingin menambahkan note ke cekdulu_qf
-- isinya di window floating atau di isi di bagian bawah cmd?
M.add_note = function()

  if not is_qf_cekdulu() then
    return
  end

  index = fn.line(".")

  local content = fn.input("INSERT > ")

  if #content == 0 then
    return
  end

  M.user_lists[index].note = content

  if config.bufnr_qf_winid ~= nil then
    M.show_note_close(config.bufnr_qf_winid)
  end

  clear_prompt()

  M.show_note_popup()

end

M.update = function(table_mode, title)

  local action = "r"
  local tryidx = "$"

  local title_ctx = title or M.title_qf

  local what = {
    title = title_ctx,
    context = title_ctx,
    items = table_mode,
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
  M.show_note_popup()

end

M.test_wrap_note = function()

  local filetype = api.nvim_buf_get_option(0, "filetype")

  if filetype == "qf" then

    if not is_qf_cekdulu() then
      return
    end

    M.buf_leave()

    index = fn.line(".")

    M.win_float_qf("qf", false, M.user_lists[index].note)
    return

  end

  if filetype == config.bufname_qf_note then

    if not api.nvim_buf_get_var(0, "floatwin_cekdulu_qf_note") == 1 then
      return
    end

    local stripped = vim.fn.getline(1, "$")
    M.user_lists[index].note = stripped

    if
      config.bufnr_qf_border_winid ~= nil
      or config.border_qf_border_winid
    then

      M.show_note_close(config.bufnr_qf_border_winid)
    end

    api.nvim_command("wincmd p")

  end

end

M.yo = function()

  print("yo")

end

M.remove = function()

  if not is_qf_window() then
    return
  end

  index = fn.line(".")

  local cektodo_lists = #M.user_lists > 0 and M.user_lists or fn.getqflist()

  deltable_by_key(cektodo_lists)

  -- Kita harus mereset table yang sudah ada menjadi nil,
  -- karena akan di timpa dengan item yang baru
  local newtable = nil

  if #M.user_lists > 0 then
    M.user_lists = {}
    newtable = M.user_lists

  else
    M.nonuser_lists = {}
    newtable = M.nonuser_lists
  end

  table_insert(newtable, cektodo_lists)

  M.update(newtable, ":setqflist()")

end

M.remove_all = function()

  M.user_lists = {}

end

return M
