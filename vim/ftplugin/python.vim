setlocal foldmethod=indent
" Include comments inside folds:
setlocal foldignore=

"map <buffer> <F1> :w<cr>:!python3 %<cr>
inoremap <buffer> pdt import pdb; pdb.set_trace()

let g:ale_linters.python = 'all'

" Line length
set colorcolumn=120
let g:ale_python_flake8_options = '--max-line-length=119'
let g:ale_python_pycodestyle_options = '--max-line-length=119'
