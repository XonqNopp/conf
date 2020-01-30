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
if &ft == "cpp"
	let b:ComChar = "//"
	let b:ComCharStart = "/*"
	let b:ComCharStop = "*/"
endif

" The F1 key
map <buffer> <F1> :w<cr>:make! %:r<cr>

