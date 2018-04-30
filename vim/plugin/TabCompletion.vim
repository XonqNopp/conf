function TabComplete()
	let col = col('.')-1
	if !col || getline('.')[col-1] !~ '\k'
		return "\<tab>"
	else
		return "\<C-X>\<C-O>"
	endif
endfunction

inoremap <Tab> <C-R>=TabComplete()<CR>
