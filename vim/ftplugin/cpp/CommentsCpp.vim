""""""""""""""""""""""""""""""""
"""""""" vimrc for cpp files
"""""""""""""""""""""""""""""""
function! UncommentCpp()
	echoerr "TO BE TESTED!!!"
	echo 'Not working well...'
	execute "normal `<"
	if col(".") == 2
		execute "normal h"
	elseif col(".") > 2
		execute "normal 2h"
	endif
	execute '/\/\*[^*]'
"	execute "normal n"
	execute "normal 2x"
	execute "normal `>2l"
	execute '?[^*]\*\/?e'
"	execute "normal `>2l"
"	execute "normal n"
	execute "normal 2X"
endfunction

" This is a string to test this function. Try it here so this is safe and you can do what you want.
