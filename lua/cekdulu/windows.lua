local config = require("cekdulu.config")

local api = vim.api
local fn = vim.fn

local M = {}

M.reset_window = function()

  local stats = api.nvim_list_uis()[1]
  local width = stats.width
  local height = stats.height

  local win_height = math.ceil(height * 0.7)
  local win_width = math.ceil(width * 0.7)

  local row = math.ceil((height - win_height) / 2)
  local col = math.ceil((width - win_width) / 2)

  config.bufnr_opts = {
    style = "minimal",
    relative = "editor",
    height = win_height - 5,
    width = win_width - 8,
    row = row + 2,
    col = col + 4,
  }

  config.bufnr_border_opts = {

    style = "minimal",
    relative = "editor",
    width = win_width + 2,
    height = win_height + 2,
    row = row - 1,
    col = col - 1,
    focusable = false,

  }

  config.bufnr_qf_opts = {

    style = "minimal",
    relative = "win",
    -- width = win_width - 20,
    width = 60,
    height = 6,
    row = row - 10,
    col = row,
    focusable = false,
    anchor = "SW", -- SW

  -- • "NW" northwest (default)
  -- • "NE" northeast
  -- • "SW" southwest
  -- • "SE" southeast

  }

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

M.create_border = function(bufnr, opts)

  local middle_line = "│" .. string.rep(" ", config.win_width) .. "│"
  local border_lines = { "╭" .. string.rep("─", config.win_width) .. "╮" }

  for _ = 1, config.win_height do
    table.insert(border_lines, middle_line)
  end

  table.insert(
    border_lines,
    "╰─"
      .. string.rep("─", config.win_width - #opts.bufname - 4)
      .. " "
      .. opts.bufname
      .. " "
      .. "─"
      .. "╯"
  )

  api.nvim_buf_set_lines(bufnr, 0, -1, false, border_lines)

end

M.create_win_border = function(go_to_window, opts)

  local buf_border = api.nvim_create_buf(false, true)
  local win_border = api.nvim_open_win(buf_border, go_to_window, opts.bufnr_border_opts)
  M.create_border(buf_border, config)
  api.nvim_buf_set_option(buf_border, "filetype", opts.bufname)
  api.nvim_win_set_option(win_border, "winhl", "Normal:Normal,EndOfBuffer:Normal")

  config.bufnr_border = buf_border
  config.border_winid = win_border

end

M.create_win_float = function(filetype, opts, contents, myfn)

  M.reset_window()

  if M.buf_exits(config.bufnr, config.bufname) then
    return
  end

  local go_to_window = true

  if filetype == "qf" then
    go_to_window = false
  end

  -- Create border buffer
  if filetype ~= "qf" then
    local buf_border = api.nvim_create_buf(false, true)
    local win_border = api.nvim_open_win(buf_border, go_to_window, opts.bufnr_border_opts)
    M.create_border(buf_border, config)
    api.nvim_buf_set_option(buf_border, "filetype", opts.bufname)
    api.nvim_win_set_option(win_border, "winhl", "Normal:Normal,EndOfBuffer:Normal")

    config.bufnr_border = buf_border
    config.border_winid = win_border
  end

  -- Buffer content
  local buf = api.nvim_create_buf(false, true)

  api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf, "buftype", "nofile")

  local win = nil

  if #contents > 0 and contents ~= nil then
    api.nvim_buf_set_lines(buf, 0, -1, true, contents)

    if filetype == "qf" then
      api.nvim_buf_set_option(buf, "filetype", opts.bufname_qf)
      api.nvim_buf_set_option(buf, "modifiable", false)
      win = api.nvim_open_win(buf, go_to_window, opts.bufnr_qf_opts)

      config.bufnr_qf_winid = win

    else
      api.nvim_buf_set_option(buf, "filetype", opts.bufname)
      win = api.nvim_open_win(buf, go_to_window, opts.bufnr_opts)
      -- api.nvim_command(":silent! 0r " .. contents)
      api.nvim_set_current_win(win)
    end
    api.nvim_win_set_option(win, "winhl", "Normal:Normal,EndOfBuffer:Normal")
  end

  buf = myfn() or buf

  return buf

end

M.close = function(winid)

  if vim.api.nvim_win_is_valid(winid) then
    api.nvim_win_close(winid, true)
  end

  --   if not pcall(function()
  --     api.nvim_win_close(winid, true)
  --   end) then
  --     -- Vim:E444: Cannot close last window

  --     print("yo bro")
  --     cmd("quit")
  --   end
end

return M
