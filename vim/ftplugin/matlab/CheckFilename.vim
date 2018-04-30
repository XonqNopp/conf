"" Script to check if the filename is equal to the matlab function name
"" G. Induni, Feb 2011
"" Last modified: Mon 2015-04-27 08:39:27 CEST
"" Version 0.1

if exists("g:loaded_checkmatlabfilename") && g:loaded_checkmatlabfilename
	call CheckMatlabFilename()
	finish
endif
let g:loaded_checkmatlabfilename = 1
let g:checkmatlabfilename_version = "0.1"

function! CheckMatlabFilename()
	let l:filename = expand("%:t:r")
	if strpart(l:filename,0,9) != "startup.m" && strpart(l:filename,1,8) != "octaverc" && strpart(l:filename,1,8) != "keleton."
		if search("function") > 0
			let l:curlin = line(".")
			execute "normal G"
			"" This must be changed to keep the previous position (i.e. to restore it after this...)
			let l:line = search("function")
			let l:theline = getline(l:line)
			if match( l:theline, "^%" ) == -1
				let l:theline = substitute( l:theline, " *\\((.*)\\)\\?$", "", "" )
				let l:theline = substitute( l:theline, "^\\s*function \\?\\(\\[\\?[^=]*\\]\\?= *\\| *\\)", "", "" )
				if l:theline != l:filename
					echoerr "You have a confusion with the filename and the function name:"
					echohl Error
					echomsg "Function name : " . l:theline
					echomsg "Filename      : " . l:filename
					echohl None
				endif
			endif
			execute "normal " . l:curlin . "G"
		endif
	endif
endfunction

call CheckMatlabFilename()

