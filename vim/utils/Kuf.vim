function! Kuf(...)
	let l:line = line(".")
	"let l:before = a:1
	"let l:after = a:2
	let l:whole = a:1 . a:2
	let l:wholenew = a:1 . l:line . a:2
	execute "s/" . l:whole . "/" . l:wholenew . "/"
	"execute "s/VALUES( , '/VALUES( " . l:line . ", '/"
endfunction
