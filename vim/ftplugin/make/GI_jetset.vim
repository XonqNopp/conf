if has("spell")
	setlocal nospell
	"" Not having the spell correction
endif
setlocal cindent
setlocal nofoldenable
setlocal foldmethod=marker
if &ft == "make"
	let b:ComChar = "#"
endif
