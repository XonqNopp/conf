"" Set default LaTeX values:
"" Limit to 80 columns for diff purpose
setlocal textwidth=80
"" make the first illegal column highlight
setlocal colorcolumn=81

if exists("g:loaded_TogTexTex") && g:loaded_TogTexTex
	finish
endif
let g:loaded_TogTexTex = 1

"" toggle textwidth for special lines
function ToggleTexTextwidth()
	if &textwidth == 0
		setlocal textwidth=80
		setlocal colorcolumn=81
	else
		setlocal textwidth=0
		setlocal colorcolumn=3
	endif
endfunction

map <buffer> <silent> <F4> :call ToggleTexTextwidth()<cr>
""
"" map Q to gq for textwidth
"nnoremap <buffer> Q gq
"nnoremap <buffer> QQ gqq
nnoremap <buffer> Q gw
nnoremap <buffer> QQ gww
