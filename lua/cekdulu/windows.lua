local config = require("cekdulu.config")

local api = vim.api
local fn = vim.fn

-- taken from lspsaga
local function get_border_style(style, highlight)

  highlight = highlight or "FloatBorder"
  local border_style = {
    ["single"] = "single",
    ["double"] = "double",
    ["round"] = {
      { "╭", highlight },
      { "─", highlight },
      { "╮", highlight },
      { "│", highlight },
      { "╯", highlight },
      { "─", highlight },
      { "╰", highlight },
      { "│", highlight },
    },
    ["bold"] = {
      { "┏", highlight },
      { "─", highlight },
      { "┓", highlight },
      { "│", highlight },
      { "┛", highlight },
      { "─", highlight },
      { "┗", highlight },
      { "│", highlight },
    },
    ["plus"] = {
      { "+", highlight },
      { "─", highlight },
      { "+", highlight },
      { "│", highlight },
      { "+", highlight },
      { "─", highlight },
      { "+", highlight },
      { "│", highlight },
    },
  }

  return border_style[style]

end

local function make_floating_popup_options(width, height, opts)

  opts = opts or {}

  local new_option = {}

  new_option.style = "minimal"
  new_option.width = width
  new_option.height = height

  if opts.relative ~= nil then
    new_option.relative = opts.relative
  else
    new_option.relative = "cursor"
  end

  if opts.anchor ~= nil then
    new_option.anchor = opts.anchor
  end

  if opts.row == nil and opts.col == nil then

    local lines_above = vim.fn.winline() - 1
    local lines_below = vim.fn.winheight(0) - lines_above
    new_option.anchor = ""

    if lines_above < lines_below then
      new_option.anchor = new_option.anchor .. "N"
      height = math.min(lines_below, height)
      new_option.row = 1
    else
      new_option.anchor = new_option.anchor .. "S"
      height = math.min(lines_above, height)
      new_option.row = -2
    end

    if vim.fn.wincol() + width <= api.nvim_get_option("columns") then
      new_option.anchor = new_option.anchor .. "W"
      new_option.col = 0
    else
      new_option.anchor = new_option.anchor .. "E"
      new_option.col = 1
    end
  else
    new_option.row = opts.row
    new_option.col = opts.col
  end

  -- print(vim.inspect(new_option))

  return new_option

end

local function generate_win_opts(contents, opts)

  opts = opts or {}
  local win_width, win_height = vim.lsp.util._make_floating_popup_size(contents, opts)

  opts = make_floating_popup_options(win_width, win_height, opts)
  return opts

end

local function create_win_with_border(content_opts, opts)

  local contents, filetype = content_opts.contents, content_opts.filetype
  local enter = content_opts.enter or false
  local modifiable = content_opts.modifiable or false
  local highlight = content_opts.highlight or "LspFloatWinBorder"
  opts = opts or {}
  opts = generate_win_opts(contents, opts)
  opts.border = get_border_style("round", highlight)

  -- print(vim.inspect(opts))
  if opts.width <= 0 then
    opts.width = 20
  end

  -- create contents buffer
  local bufnr = api.nvim_create_buf(false, true)
  -- buffer settings for contents buffer
  -- Clean up input: trim empty lines from the end, pad
  local content = vim.lsp.util._trim(contents)

  if filetype then
    api.nvim_buf_set_option(bufnr, "filetype", filetype)
  end

  -- print(vim.inspect(opts))

  api.nvim_buf_set_lines(bufnr, 1, -1, true, content)
  api.nvim_buf_set_option(bufnr, "modifiable", modifiable)
  api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  api.nvim_buf_set_option(bufnr, "buftype", "nofile")

  local winid = api.nvim_open_win(bufnr, enter, opts)
  if filetype == "markdown" then
    api.nvim_win_set_option(winid, "conceallevel", 2)
  end

  -- api.nvim_win_set_option(
  --   winid,
  --   "winhl",
  --   "Normal:NormalFloat,FloatBorder:" .. highlight
  -- )

  api.nvim_win_set_option(winid, "winhl", "Normal:Normal,EndOfBuffer:Normal")

  api.nvim_win_set_option(winid, "winblend", 0)
  api.nvim_win_set_option(winid, "foldlevel", 100)
  return bufnr, winid

end

local M = {}

M.reset_window = function()

  local stats = api.nvim_list_uis()[1]
  local width = stats.width
  local height = stats.height

  local win_height = math.ceil(height * 0.7)
  local win_width = math.ceil(width * 0.7)

  local row = math.ceil((height - win_height) / 2)
  local col = math.ceil((width - win_width) / 2)

  config.col = col
  config.row = row
  config.win_height = win_height
  config.win_width = win_width

end

M.buf_exits = function(bufnr, bufname)

  local status, exists = pcall(function()
    return (
        bufnr ~= nil
        and api.nvim_buf_is_valid(bufnr)
        and api.nvim_buf_get_var(bufnr, "nvim_tree_buffer_ready") == 1
        and fn.bufname(bufnr) == bufname
      )
  end)

  if not status then
    return false
  else
    return exists
  end

end

M.wipeout_buffer = function(bufnr)

  -- NOTE: we need this command, untuk mendelete buffer border
  --       jadi saat kita create buffer cekdulu..lalu kita-close-or-quit,
  --       buffer border akan di delete dengan command ini
  api.nvim_command(
    "au BufWipeout <buffer> exe \"silent bwipeout! \"" .. bufnr
  )

end

M.create_win_float_with_border = function(opts, contents, func)

  local content_opts = {
    contents = contents,
    filetype = opts.bufname,
    enter = opts.enter,
    modifiable = true,
    highlight = "LspSagaSignatureHelpBorder",
  }

  local buf, win = create_win_with_border(content_opts, opts)

  func(buf, win)    -- nothing todo..

end

M.close = function(winid)

  -- print("closing ", winid)

  if winid and winid ~= nil then
    if vim.api.nvim_win_is_valid(winid) then
      api.nvim_win_close(winid, true)
    end
  end

end

return M
