if has("spell")
	setlocal nospell
	"" Not having the spell correction
endif

setlocal noexpandtab
setlocal cindent
setlocal nofoldenable
setlocal foldmethod=marker

if &ft == "make"
	let b:ComChar = "#"
endif
