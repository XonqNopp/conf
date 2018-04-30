if has("spell")
	setlocal nospell
	"" Not having the spell correction
endif
setlocal cindent
setlocal foldmethod=indent
if &ft == "matlab"
	let b:ComChar = "%"
endif
