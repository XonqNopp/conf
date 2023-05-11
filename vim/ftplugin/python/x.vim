setlocal foldmethod=indent
" Include comments inside folds:
setlocal foldignore=

"map <buffer> <F1> :w<cr>:!python3 %<cr>
inoremap <buffer> pdt import pdb; pdb.set_trace()

let g:ale_linters.python = "all"
