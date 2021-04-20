local api = vim.api

local function set_mappings(buf)

  local mappings = {
    ["<c-b>"] = "set_list_todo()",
    ["<tab>"] = "toggle_list_todo()",
    ["<c-space>"] = "set_list_toggle()",
    ["<c-v>"] = "open_on_buftab(\"vsplit\")",
    ["<c-s>"] = "open_on_buftab()",
    ["<c-t>"] = "open_on_buftab(\"tabnew\")",
  }

  for k, v in pairs(mappings) do

    api.nvim_buf_set_keymap(buf, "n", k, ":lua require\"cekdulu.todo\"." .. v .. "<cr>", {
      nowait = true,
      noremap = true,
      silent = true,
    })
  end

  local ignore_mappings = {
    "<c-o>",
    -- "<c-i>",
    "<c-w>w",
  }

  for _, v in ipairs(ignore_mappings) do
    api.nvim_buf_set_keymap(buf, "n", v, "", {
      nowait = true,
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(buf, "n", v:upper(), "", {
      nowait = true,
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(buf, "n", "<c-" .. v .. ">", "", {
      nowait = true,
      noremap = true,
      silent = true,
    })
  end

end

return {

  set_mappings = set_mappings,
}
