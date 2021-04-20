local config = require("cekdulu.config")
local load_data = require("cekdulu.load-data")
local windows = require("cekdulu.windows")
local mappings = require("cekdulu.mappings")

local api = vim.api
local fn = vim.fn
local line = nil
local lsp = vim.lsp
local mode = 0

local function clear_bufnr_from_buflists(pattern_bufname)

  for _, i in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(i) and fn.buflisted(i) ~= 0 then
      if api.nvim_buf_get_name(i):match(".*/" .. pattern_bufname .. "$") then
        vim.cmd("bdelete! " .. i)
      end
    end
  end

end

local M = {}

local load_contents = function()

  local output_table_string_path_todo = fn.systemlist("cat " .. config.path_todo)

  local contents = { "" }

  if #output_table_string_path_todo > 0 then

    -- delete unwanted lines from contents ( from `cat command` output)
    local stripped = lsp.util._trim(output_table_string_path_todo)
    contents = lsp.util.convert_input_to_markdown_lines(stripped)

    return contents

  end

  -- harus dipastikan contents setidaknya mempunyai isi,
  -- dengen length list 1
  return contents

end

M.win_float_todo = function()

  windows.reset_window()

  local contents = load_contents()

  config.relative = "editor"
  config.enter = true
  config.height = config.win_height - 15
  config.width = config.win_width

  windows.create_win_float_with_border(config, contents, function(buf, win)
    config.bufnr_todo_winid = win

  end)

end

M.win_stack_todo = function()

  -- TODO: create stack todo win

end

-- 'unchecked': '  ',
-- 'checked':   '  ',
-- 'loading':   '  ',
-- 'error':     '  ',

M.set_list_done = function()

  mode = 1

  line = fn.getline(".")
  fn.setline(".", fn.substitute(line, "^\\(\\s*\\) ", "\\1 ", ""))

end

M.set_list_not_done = function()

  mode = 0

  line = fn.getline(".")
  fn.setline(".", fn.substitute(line, "^\\(\\s*\\) ", "\\1 ", ""))

end

M.check_list = function()

  line = fn.getline(".")

  if fn.match(line, "^\\s* .*") == -1 then
    mode = 0
    return true

  elseif fn.match(line, "^\\s* .*") == -1 then
    mode = 1
    return true

  else
    return false

  end

end

M.check_all_list = function()

  line = fn.getline(".")

  if fn.match(line, "^\\s*\\( \\| \\).*") == -1 then
    mode = 0
    return true
  end

  mode = 1
  return false

end

M.is_date_is_set = function()

  line = fn.getline(".")

  local already_dated = fn.matchstr(line, "@\\d\\{2\\}-\\d\\{2\\}-\\d\\{2,4\\}")

  if #already_dated > 0 then
    return true
  end

  return false

end

M.append_date = function()

  local date = fn.strftime("%d-%m-%Y")
  vim.cmd(string.format(":normal! A @%s", date))

end

M.set_list_todo = function()

  if not M.is_date_is_set() then
    M.append_date()
  end

  if not M.check_all_list() and mode == 1 then
    return
  end

  line = fn.getline(".")
  fn.setline(".", fn.substitute(line, "^\\s*", "\\1 @todo: ", ""))

end

M.toggle_list_todo = function()

  line = fn.getline(".")

  if fn.match(line, "@todo") > 0 then
    fn.setline(".", fn.substitute(line, "@todo", "@fixme", ""))
    return
  end

  if fn.match(line, "@fixme*") > 0 then
    fn.setline(".", fn.substitute(line, "@fixme", "@question", ""))
    return
  end

  if fn.match(line, "@question*") > 0 then
    fn.setline(".", fn.substitute(line, "@question", "@todo", ""))
    return
  end

end

M.set_list_toggle = function()

  if M.check_list() and mode == 0 then
    M.set_list_done()
    return
  end

  M.set_list_not_done()

end

--------------------------------------
--------------------------------------

M.save = function()

  if config.path_todo ~= nil and config.path_todo then
    api.nvim_command(":silent! w " .. config.path_todo)
  end

end

M.close = function()

  clear_bufnr_from_buflists(config.fname_todo)

  local filetype = api.nvim_buf_get_option(0, "filetype")

  if filetype == config.bufname then
    M.save()
    windows.close(config.bufnr_todo_winid)
    return true
  end

  return false

end

M.open_on_buftab = function(modetab)

  M.close()

  api.nvim_command(string.format("%s %s", modetab, config.path_todo))

end

M.open = function()

  if not load_data.validate_path(config, "todo") then
    return
  end

  M.win_float_todo()

  mappings.set_mappings()

end

return M
