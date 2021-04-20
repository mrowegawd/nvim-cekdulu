
if exists("b:current_syntax")
    finish
endif

syntax  region  TodoDone start="\/\*" end="\*\/"                  contains=TodoDone

syntax  match   TodoDone        '\s.\+$'                         contains=TodoKey,TodoDate,TodoProject,TodoContext
syntax  match   TodoPriorityA   '^([aA])\s.\+$'                   contains=TodoDate,TodoProject,TodoContext,OverDueDate

" syntax  match   TodoDate        '\d\{2\}-\d\{2\}-\d\{2,4\}'       contains=NONE
syntax  match   TodoDate        '\d\{2\}-\d\{2\}-\d\{2,4\}'

syntax  match   TodoQuestion    /@ques[a-z]*/
syntax  match   Todotag         /@todo[a-zA-Z]*/
syntax  match   TodoFixme       /@fixm[a-z]*/

" syntax  match  TodoDone       '\[[xX]\]\s.\+$'       contains=TodoKey,TodoDate,TodoProject,TodoContext
" syntax  match  TodoPriorityB  '^([bB])\s.\+$'             contains=TodoDate,TodoProject,TodoContext,OverDueDate

highlight  default  link  TodoDone       Comment
highlight  default  link  TodoPriorityA  Constant
highlight  default  link  TodoPriorityB  Statement
highlight  default  link  TodoDate       PreProc

highlight  default  link  TodoQuestion   Question
highlight  default  link  Todotag        Todo
highlight  default  link  TodoFixme      ErrorMsg

let b:current_syntax = "cekdulu"
