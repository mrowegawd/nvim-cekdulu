if !has('nvim-0.5') || exists('g:loaded_cekdulu') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

" delete this -----
fun! MyfirstPlugin()
  lua for k in pairs(package.loaded) do if k:match('^cekdulu')
        \ then package.loaded[k] = nil end end
  lua require'cekdulu'
endfunction
" end delete

if !exists('g:cekdulu_path')
  let g:cekdulu_path = $HOME . '/Dropbox/vimwiki/todo'
endif

if !exists('g:cekdulu_qf_load')
  let g:cekdulu_qf_load = 0
endif

if !exists('g:cekdulu_fname_todo')
  let g:cekdulu_fname_todo = "cekdulu_todo"
endif

if !exists('g:cekdulu_fname_qf')
  let g:cekdulu_fname_qf = "cekdulu_qf.json"
endif

command! CekduluToggle lua require'cekdulu'.todo_toggle()

command! CekduluqfLoad lua require'cekdulu'.qf_load()
command! CekduluqfRemove lua require'cekdulu'.qf_remove()

command! CekduluTodoTest lua require'cekdulu.todo'.test()

command! CekduluqfAdd lua require'cekdulu'.add()
command! CekduluqfSave lua require'cekdulu'.save()
command! CekduluqfNoteAdd lua require'cekdulu'.add_note()

command! CekduluqfTestWrap lua require'cekdulu'.test_wrap_note()
command! CekduluqfYo lua require'cekdulu'.yo()

command! CekduluDash lua require'cekdulu'.dash_toggle()
command! CekduluDashClose lua require'cekdulu'.dash_close()

command! Keep lua require'cekdulu.qf'.qf_fkeep('freject')

" command! CekduluYak lua require'cekdulu.qf'.enable()

augroup TestingCekdulu
    autocmd!
    autocmd FileType qf lua require('cekdulu.qf').enable()
augroup END

" delete this ----------
nnoremap rr :call MyfirstPlugin()<CR>

augroup MyfirstPlugin
  autocmd!
augroup END
" end delete

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_cekdulu = 1
