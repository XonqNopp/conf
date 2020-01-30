setlocal cindent
setlocal foldmethod=indent
setlocal expandtab
setlocal tabstop=4
" Include comments inside folds:
setlocal foldignore=
setlocal textwidth=119
setlocal colorcolumn=120

map <buffer> <F1> :w<cr>:!python3 %<cr>
inoremap <buffer> pdt import pdb; pdb.set_trace()

