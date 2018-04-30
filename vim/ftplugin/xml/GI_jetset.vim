setlocal cindent
setlocal foldmethod=indent
if &ft == "xml"
	"" To (un)comment
	let b:ComCharStart = "<!--"
	let b:ComCharStop  = "-->"
endif
