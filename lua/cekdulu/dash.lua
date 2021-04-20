local config = require("cekdulu.config")
local windows = require("cekdulu.windows")

local api = vim.api
local g = vim.g
local fn = vim.fn

local indent = "      "

local set_option = function(bufnr, name, value, win)

  if win then
    return vim.api.nvim_win_set_option(bufnr, name, value)
  else
    return vim.api.nvim_buf_set_option(bufnr, name, value)
  end

end

local M = {

  bufnr = nil,
  bufnr_win = nil,
  contents = {},

}

M.namespace = vim.api.nvim_create_namespace("LspTrouble")

M.set_lines = function(lines, first, last, strict)

  first = first or 0
  last = last or -1
  strict = strict or false
  return vim.api.nvim_buf_set_lines(M.bufnr, first, last, strict, lines)

end

local format_path = function(path)

  return string.format("%s/%s/%s", g.cekdulu_path, path, config.fname_todo)

end

M.render_contents = function()

  M.contents = fn.systemlist("ls " .. g.cekdulu_path)

  local custom_contents = {}

  for i = 1, #M.contents do
    table.insert(
      custom_contents,
      string.format(
        "%sProject: %s %s <> %s %s %s",
        indent,
        M.contents[i],
        indent,
        M.cat_ash(format_path(M.contents[i]), "todo"),
        M.cat_ash(format_path(M.contents[i]), "question"),
        M.cat_ash(format_path(M.contents[i]), "fixme")
      )
    )
  end

  M.set_lines(custom_contents, -1)

end

M.create_buf = function()

  vim.cmd("below new")
  vim.cmd("wincmd J")

  vim.cmd("setlocal nonu")
  vim.cmd("setlocal nornu")

  M.bufnr = api.nvim_get_current_buf()

  set_option(M.bufnr, "bufhidden", "wipe")
  set_option(M.bufnr, "filetype", config.bufname_dash)
  set_option(M.bufnr, "buftype", "nofile")
  set_option(M.bufnr, "swapfile", false)
  set_option(M.bufnr, "buflisted", false)

end

M.setup = function()

  M.create_buf()

  M.render_contents()

  M.bufnr_win = vim.api.nvim_get_current_win()

  set_option(M.bufnr_win, "winfixwidth", true, true)
  set_option(M.bufnr_win, "spell", false, true)
  set_option(M.bufnr_win, "list", false, true)
  set_option(M.bufnr_win, "winfixheight", true, true)
  set_option(M.bufnr_win, "signcolumn", "no", true)
  set_option(M.bufnr_win, "foldmethod", "manual", true)
  set_option(M.bufnr_win, "foldcolumn", "0", true)
  set_option(M.bufnr_win, "foldlevel", 3, true)
  set_option(M.bufnr_win, "foldenable", false, true)

  set_option(M.bufnr, "readonly", true)
  set_option(M.bufnr, "modifiable", false)

  set_option(
    M.bufnr_win,
    "winhl",
    "Normal:Normal,EndOfBuffer:Normal",
    true
  )

  api.nvim_win_set_height(M.bufnr_win, #M.contents + 3)

  -- vim.api.nvim_buf_clear_namespace(M.bufnr, M.namespace, 0, -1)

  -- print(vim.fn.win_getid(vim.fn.winnr('#')))
  vim.cmd("norm! zz zv")

  vim.api.nvim_win_set_cursor(M.bufnr_win, { 2, 0 })

end

M.close = function()

  windows.close(M.bufnr_win)

end

M.toggle = function()

  M.setup()

end

-- CUSTOM TEXT ---------------------------------------------------------

M.cat_ash = function(path, mystring)

  local content = fn.systemlist(string.format("cat %s | grep -i @%s", path, mystring))

  return string.format("%s @%s", #content, string.upper(mystring))

end

return M
