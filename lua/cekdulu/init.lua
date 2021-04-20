local config = require("cekdulu.config")
local todo = require("cekdulu.todo")
local dash = require("cekdulu.dash")
local qf = require("cekdulu.qf")

-- local g = vim.g

config.init()

-- 1. user when cekdulu.toggle, open open todo dan load cekdulu_qf untuk line code
--    (jika tidak cekdulu_qf, ignore loadnya)
--
--    kendala:
--      - ketika user trigger cekdulu.toggle, cekdulu_qf terload namun ketika di
--      trigger kembali, jika file berisi table tersebut punya isi

local function todo_toggle()

  if todo.close() then return end

  todo.open()

end


local function qf_load()

  qf.load()

end

local function qf_remove()

  qf.remove()

end

local function dash_toggle()

  dash.toggle()

end

local function dash_close()

  dash.close()

end

return {

  todo_toggle = todo_toggle,

  qf_load = qf_load,
  qf_remove = qf_remove,

  add = qf.add,
  save = qf.save,
  add_note = qf.add_note,
  test_wrap_note = qf.test_wrap_note,
  yo = qf.yo,

  dash_toggle = dash_toggle,
  dash_close = dash_close,

}
