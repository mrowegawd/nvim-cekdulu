local config = require("cekdulu.config")
local todo = require("cekdulu.todo")
local qf = require("cekdulu.qf")

local g = vim.g

require('cekdulu.config').init()

-- 1. user when cekdulu.toggle, open open todo dan load cekdulu_qf untuk line code
--    (jika tidak cekdulu_qf, ignore loadnya)
--
--    kendala:
--      - ketika user trigger cekdulu.toggle, cekdulu_qf terload namun ketika di
--      trigger kembali, jika file berisi table tersebut punya isi
--

local function cekdulu_toggle()

  if not config.bufnr_created then
    todo.open()

    if g.cekdulu_qf_load ~= nil and g.cekdulu_qf_load == 1 then
      if config.is_cekdulu_created then
        qf.load()
      end
    end

    return

  end

  config.bufnr_created = false

  todo.close_todo()

end

return {

  cekdulu_toggle = cekdulu_toggle,

  add = qf.add,
  load = qf.load,
  save = qf.save,
  remove = qf.remove,
  add_note = qf.add_note,
  test_wrap_note = qf.test_wrap_note,
  yo = qf.yo,

}
