setlocal cinwords=if,else,elseif,while,do,for,function,switch
setlocal nosmartindent
setlocal cindent
setlocal foldmethod=indent
if &ft == "c"
	let b:ComChar = "//"
	let b:ComCharStart = "/*"
	let b:ComCharStop = "*/"
endif

" The F1 key
map <buffer> <F1> :update<cr>:make<cr>
