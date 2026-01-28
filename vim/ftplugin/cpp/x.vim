function! UncommentCpp()
	echoerr "TO BE TESTED!!!"
	echo 'Not working well...'
	execute "normal `<"
	if col(".") == 2
		execute "normal h"
	elseif col(".") > 2
		execute "normal 2h"
	endif
	execute '/\/\*[^*]'
	"execute "normal n"
	execute "normal 2x"
	execute "normal `>2l"
	execute '?[^*]\*\/?e'
	"execute "normal `>2l"
	"execute "normal n"
	execute "normal 2X"
endfunction

" This is a string to test this function. Try it here so this is safe and you can do what you want.

setlocal cinwords=if,else,elseif,while,do,for,function,switch
setlocal nosmartindent
setlocal cindent
setlocal foldmethod=indent
setlocal tabstop=4
setlocal expandtab
setlocal textwidth=120
setlocal colorcolumn=121

" Debug
" See https://medium.com/@948/how-does-debugging-with-vim-and-gdb-3ab5ed0dcd0f
let g:termdebug_popup = 0
let g:termdebug_wide = 163
packadd termdebug

if &ft == "cpp"
	let b:ComChar = "//"
	let b:ComCharStart = "/*"
	let b:ComCharStop = "*/"
endif

" The F1 key
map <buffer> <F1> :w<cr>:make! %:r<cr>

" Split commands for header file
command! Sph SpitUp %:r.hpp
command! Spp SpitDown %:r.cpp

