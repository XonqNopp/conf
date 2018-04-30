function! InsertNumberLikeLine(pattern,...)
	"" add parameter to insert somthing more than the number
	let l:offset = 0
	if a:0 > 0
		let l:offset = a:1
	endif
	let l:line = line(".")
	let l:nmb = l:line + l:offset
	execute "s/" . a:pattern . "/" . l:nmb . "/"
endfunction
