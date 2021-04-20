local load_data = require("cekdulu.load-data")
local config = require("cekdulu.config")
local windows = require("cekdulu.windows")
local mappings = require("cekdulu.mappings")

local api = vim.api
local fn = vim.fn

local M = {}

M.win_float_todo = function()

  local output_table_string_path_todo = fn.systemlist("cat " .. config.path_todo)

  -- delete unwanted lines from tables (`cat command` output)
  local stripped = vim.lsp.util._trim(output_table_string_path_todo)
  local contents = vim.lsp.util.convert_input_to_markdown_lines(stripped)

  local buf = windows.create_win_float("todo", config, contents)

  config.bufnr_winid = buf.win

  -- NOTE: ketika window cekdulu spawned, apply these options
  for _, opt in pairs(config.options) do
    api.nvim_command("setlocal " .. opt)
  end

  config.bufnr_created = true

  api.nvim_buf_set_var(buf.buf, "float_cekdulu_todo_win", 1)

  windows.wipeout_buffer(config.bufnr_border)

end

M.win_stack_todo = function()

  -- TODO: another stack window like __scratch__

end

local mode = 0
-- 'unchecked': '  ',
-- 'checked':   '  ',
-- 'loading':   '  ',
-- 'error':     '  ',

M.set_list_done = function()

  mode = 1

  local line = fn.getline(".")
  fn.setline(".", fn.substitute(line, "^\\(\\s*\\) ", "\\1 ", ""))

end

M.set_list_not_done = function()

  mode = 0

  local line = fn.getline(".")
  fn.setline(".", fn.substitute(line, "^\\(\\s*\\) ", "\\1 ", ""))

end

M.check_list = function()

  local line = fn.getline(".")

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

  local line = fn.getline(".")

  if fn.match(line, "^\\s*\\( \\| \\).*") == -1 then
    mode = 0
    return true
  end

  mode = 1
  return false

end

M.is_date_is_set = function()

  local line = fn.getline(".")

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

  local line = fn.getline(".")
  fn.setline(".", fn.substitute(line, "^\\s*", "\\1 ", ""))

end

M.set_list_toggle = function()

  if M.check_list() and mode == 0 then
    M.set_list_done()
    return
  end

  M.set_list_not_done()

end

M.win_open = function()

  return config.winnr() ~= nil

end

-- FITUR: tambahkan show_path agar ketika berada pada filetype cekdulu
-- mempunyai fitur untuk di buka di current buffer, split atau new path..
-- dan di bukanya pake mapping
M.show_path = function()

  if config.path_todo ~= nil then
    print(config.path_todo)
  end

end

M.open = function()

  if not load_data.validate_path(config.path_todo) then
    return
  end

  M.win_float_todo()

  mappings.set_mappings()

  return true

end

M.save_to_file = function()

  local filetype = api.nvim_buf_get_option(api.nvim_get_current_buf(), "filetype")

  if filetype == config.bufname and config.path_todo ~= nil then
    api.nvim_command(":silent! w " .. config.path_todo)
  end

end

M.close_todo = function()

  local filetype = api.nvim_buf_get_option(api.nvim_get_current_buf(), "filetype")

  if filetype ~= config.bufname then
    return
  end

  if not api.nvim_buf_get_var(0, "float_cekdulu_todo_win") == 1 then
    return
  end

  M.save_to_file()
  windows.close(config.bufnr_winid)
end

return M
