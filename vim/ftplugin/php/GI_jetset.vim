setlocal cinwords=if,else,elseif,while,do,for,function,switch
setlocal cindent
setlocal foldmethod=indent
setlocal textwidth=120
if &ft == "php"
	let b:ComChar = "//"
	let b:ComCharStart = "/*"
	let b:ComCharStop = "*/"
endif
