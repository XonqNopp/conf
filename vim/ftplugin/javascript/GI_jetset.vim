setlocal cindent
setlocal foldmethod=indent
if &ft == "javascript"
	let b:ComChar = "//"
	let b:ComCharStart = "/*"
	let b:ComCharStop = "*/"
endif
