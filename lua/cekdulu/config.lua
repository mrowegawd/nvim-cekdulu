local utils = require("cekdulu.utils")

-- local api = vim.api
local fn = vim.fn
local g = vim.g
local plugin_name = "cekdulu"

local M = {}


M = {
  bufname = plugin_name,

  bufname_dash = plugin_name .. "_dash", -- cekdulu_dash

  bufnr_todo_bufname = plugin_name .. "_todo",  -- cekdulu_todo
  -- bufnr_todo_bufnr = nil,
  bufnr_todo_winid = nil,
  -- bufnr_todo_opts = {},
  -- bufnr_todo_Border_winid = nil,
  -- bufnr_todo_Border_opts = {},

  bufnr_qf_bufname = plugin_name .. "_qf", -- cekdulu_qf
  -- bufnr_qf_bufnr = nil,
  bufnr_qf_winid = nil,
  -- bufnr_qf_opts = {},
  -- bufnr_qf_Border_winid = nil,
  -- bufnr_qf_Border_opts = {},

  bufnr_note_bufname = plugin_name .. "_note", -- cekdulu_note
  -- bufnr_note_bufnr = nil,
  bufnr_note_winid = nil,
  -- bufnr_note_opts = {},
  -- bufnr_note_Border_winid = nil,
  -- bufnr_note_Border_opts = {},

  -- bufnr_dashboard_bufname = plugin_name .. "_dashboard",
  -- bufnr_dashboard_bufnr = nil,
  -- bufnr_dashboard_winid = nil,
  -- bufnr_dashboard_opts = {},
  -- bufnr_dashboard_Border_winid = nil,
  -- bufnr_dashboard_Border_opts = {},

  -- bufnr_winid = nil,
  -- bufnr_opts = {},
  -- bufnr_border_winid = nil,
  -- bufnr_border_opts = {},

  -- col = nil,
  -- row = nil,
  -- win_height = nil,
  -- win_width = nil,

  -- path_todo = "",
  -- path_qf = "",

  -- cekdulu_path = nil,

  -- is_cekdulu_created = false,

  -- options = {
  --   "noswapfile",
  --   "norelativenumber",
  --   "nonumber",
  --   "nolist",
  --   "winfixwidth",
  --   "winfixheight",
  --   "nofoldenable",
  --   "nospell",
  --   "foldmethod=manual",
  --   "foldcolumn=0",
  -- -- "signcolumn=yes",
  -- },
  -- winnr = function()
  --   for _, i in ipairs(api.nvim_list_wins()) do
  --     if
  --     -- api.nvim_buf_get_name(api.nvim_win_get_buf(i)):match(".*/" .. M.bufname .. "$")
  --       api.nvim_buf_get_name(api.nvim_win_get_buf(i))
  --     then
  --       return i
  --     end
  --   end
  -- end,

  create_files = {},
  create_folders = {},

}

M.init = function()

  M.cekdulu_path = g.cekdulu_path
    .. "/"
    .. utils.create_filename()
    or fn.resolve(fn.getcwd())
    .. "/."
    .. plugin_name

  M.fname_todo = g.cekdulu_fname_todo or M.bufnr_todo_bufname
  M.fname_qf = g.cekdulu_fname_qf or M.bufnr_qf_bufname .. ".json"

  -- print(M.cekdulu_path)

  M.path_todo = M.cekdulu_path .. "/" .. M.fname_todo
  M.path_qf = M.cekdulu_path .. "/" .. M.fname_qf

  M.create_files = {
    M.path_todo,
    M.path_qf,
  }

  M.create_folders = {
    M.cekdulu_path,
  }

  -- print(M.path_todo)
  -- print(M.path_qf)

  -- print(M.fname_todo)
  -- print(M.fname_qf)

  -- print(M.cekdulu_path)

end

return M
