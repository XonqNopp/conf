setlocal foldmethod=marker
setlocal foldminlines=3
setlocal cindent
if &ft == "vim"
	"" To (un)comment
	let b:ComChar = "\""
endif
