local utils = require("cekdulu.utils")

local fn = vim.fn
local g = vim.g

local M = {}

M = {

  folders = {},
  files = {},

}

M.check_filereadble = function(filepath)

  return fn.filereadable(filepath) ~= 0 and true or false

end

M.create_filesystem = function(path)

  fn.systemlist(string.format("touch %s", path))

end

M.create_foldersystem = function(path)

  fn.systemlist(string.format("mkdir -p %s", path))

end

-- local build_under_current_dir = function()
--   return string.format("%s/.cekdulu", fn.resolve(fn.getcwd()))
-- end

local function exec_systemlist(tbl, func)

  if #tbl == 0 then
    return
  end

  for i = 1, #tbl do
    func(tbl[i])
  end

end

local create_from_user_input = function(msg)

  local ans = fn.input(msg)

  if ans == "y" or ans == "yes" then

    utils.clear_prompt()

    exec_systemlist(M.folders, function(i)
      M.create_foldersystem(i)
    end)

    exec_systemlist(M.files, function(i)
      M.create_filesystem(i)
    end)

    return true

  end

  utils.clear_prompt_with_print()

  return false

end

local build_todo_project = function()

  if g.cekdulu_path == nil then

    return create_from_user_input(
      "global cekdulu_path is empty,"
        .. " are you sure want to create under your current project path? y/n "
    )

  else

    return create_from_user_input("create todo? y/n: ")

  end

end

-- Mengecek apakah validate untuk qf atau todo..
M.validate_path = function(opts, mode)

  if mode == "todo" then
    if not M.check_filereadble(opts.path_todo) then

      M.folders = opts.create_folders
      M.files = opts.create_files

      return build_todo_project()
    end

    opts.is_cekdulu_created = true
    return true
  end

  if mode == "qf" then
    print("creating path for qf??")
  end

  return false

end

return M
