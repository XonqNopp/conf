"autocmd VimResized * let dif_col = 148 - &columns
"autocmd VimResized * let &wrapmargin = 69 - dif_col

setlocal cinwords=if,else,elseif,while,do,for,function,switch
setlocal nosmartindent
setlocal cindent
" To have smart indentation in blocks
setlocal foldmethod=indent
setlocal foldlevel=1
" tabstop and shiftwidth must be same size:
setlocal tabstop=4
setlocal shiftwidth=4
setlocal expandtab
"setlocal columns=148
setlocal textwidth=72 "" including 6 first spaces
setlocal colorcolumn=73 "" too late
if &ft == "fortran"
	"" Choose a comment character: ! is also useable inline
	let b:ComChar = "!"
endif

" The F1 key
map <buffer> <F1> :update<cr>:make<cr>

