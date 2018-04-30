setlocal foldmethod=indent
if &ft == "html"
	"" (un)comment
	let b:ComCharStart = "<!--"
	let b:ComCharStop  = "-->"
endif
