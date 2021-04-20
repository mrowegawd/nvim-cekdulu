local config = require("cekdulu.config")
local utils = require("cekdulu.utils")

local fn = vim.fn
local g = vim.g

local check_filereadble = function(filepath)
  return fn.filereadable(filepath) ~= 0 and true or false
end

local create_filesystem = function()
  fn.systemlist(string.format("mkdir -p %s", config.cekdulu_path))
  fn.systemlist(string.format("touch %s", config.path_todo))
  fn.systemlist(string.format("touch %s", config.path_qf))

end

-- local build_under_current_dir = function()
--   return string.format("%s/.cekdulu", fn.resolve(fn.getcwd()))
-- end

local user_input = function(msg)
  local ans = fn.input(msg)

  if ans == "y" or ans == "yes" then

    utils.clear_prompt()
    create_filesystem()
    return true

  end

  utils.clear_prompt_with_print()

  return false
end

local build_todo_project = function()

  if g.cekdulu_path == nil then

    return user_input(
      "global cekdulu_path is empty,"
        .. " are you sure want to create under your current project path? y/n "
    )

  else

    return user_input("create todo? y/n: ")

  end

end

local validate_path = function(path)
  if not check_filereadble(path) then
    return build_todo_project()
  end

  config.is_cekdulu_created = true
  return true
end

return {

  validate_path = validate_path,
  check_filereadble = check_filereadble,

}
