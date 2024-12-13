setlocal cindent
setlocal tabstop=7
setlocal shiftwidth=2
setlocal foldmethod=indent
if &ft == "javascript"
	let b:ComChar = "//"
	let b:ComCharStart = "/*"
	let b:ComCharStop = "*/"
endif
