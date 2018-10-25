""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""   Vim script written and maintained by Gael Induni
"" Created      : Thu 12 Sep 2013 01:05:39 PM CEST
"" Last modified: Thu 12 Sep 2013 01:10:19 PM CEST
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""
"" Set default LaTeX values:
"" Limit to 120 columns for diff purpose
setlocal textwidth=120
"" make the first illegal column highlight
setlocal colorcolumn=121

if exists("g:loaded_TogTexTex") && g:loaded_TogTexTex
	finish
endif
let g:loaded_TogTexTex = 1

"" toggle textwidth for special lines
function ToggleTexTextwidth()
	if &textwidth == 0
		setlocal textwidth=120
		setlocal colorcolumn=121
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
