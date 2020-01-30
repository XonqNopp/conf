"" To have smart indentation in blocks
setlocal cindent
setlocal foldmethod=indent
"setlocal t_Co=256
if &ft == "css"
	let b:ComCharStart = "/*"
	let b:ComCharStop  = "*/"
endif
