local utils = require("cekdulu.utils")

local api = vim.api
local fn = vim.fn
local g = vim.g

local M = {}

M = {
  bufname = "cekdulu",
  bufname_qf = "cekdulu_qf",
  bufname_qf_note = "cekdulu_qf",

  bufnr = nil,
  bufnr_opts = {},
  bufnr_winid = nil,
  bufnr_created = false,

  bofnr_border = nil,
  bufnr_border_opts = {},
  bufnr_border_winid = nil,

  bufnr_qf = nil,
  bufnr_qf_opts = {},
  bufnr_qf_winid = nil,

  bofnr_qf_border = nil,
  bufnr_qf_border_opts = {},
  bufnr_qf_border_winid = nil,

  win_height = nil,
  win_width = nil,

  path_todo = nil,
  path_qf = nil,

  options = {
    "noswapfile",
    "norelativenumber",
    "nonumber",
    "nolist",
    "winfixwidth",
    "winfixheight",
    "nofoldenable",
    "nospell",
    "foldmethod=manual",
    "foldcolumn=0",
  -- "signcolumn=yes",
  },
  winnr = function()
    for _, i in ipairs(api.nvim_list_wins()) do
      if
        api.nvim_buf_get_name(api.nvim_win_get_buf(i)):match(".*/" .. M.bufname .. "$")
      then
        return i
      end
    end
  end,

  is_cekdulu_created = false,
}


M.init = function()

  M.cekdulu_path = g.cekdulu_path
    .. "/"
    .. utils.create_filename()
    or fn.resolve(fn.getcwd())
    .. "/.cekdulu"

  M.qf_fname = g.cekdulu_qf_fname or "cekdulu_qf.json"
  M.todo_fname = g.cekdulu_todo_fname or "cekdulu_todo"

  M.path_todo = M.cekdulu_path .. "/" .. M.todo_fname
  M.path_qf = M.cekdulu_path .. "/" .. M.qf_fname

  -- print(M.path_todo)

end

return M
