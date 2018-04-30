""""""""""""""""""""""""""""""""""""""""""""""""""""
""""" Gael's foldtext() function for .vim files
""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FoldVim()
	let l:one = v:foldstart
	let l:lastl = v:foldend
	let l:inter = l:lastl - l:one
	let l:line = getline( l:one )
	let l:chars = '\"\+\s\|{{{[0-9]*'
	let l:substract = substitute( l:line, l:chars, '', 'g' )
	let l:return = "\+" . v:folddashes . " " . l:one . " to " . l:lastl . " (" . l:inter . " lines) : " . l:substract
	return l:return
endfunction

" vim: nofoldenable :
