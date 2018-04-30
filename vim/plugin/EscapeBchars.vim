""""""""""""""""""""""""""""""""""""""""""""""""""""
""  Plugin written and maintained by Gael Induni
"" This is EscapeBchars plugin to escape chars in b: vars
""  Last modified: Sun 24 Mar 2013 05:47:40 PM CET
""  Version 0.4
""""""""""""""""""""""""""""""""""""""""""""""""""""
"" To be always up-to-date:
"" GetLatestVimScripts: 4081 1 :AutoInstall: EscapeBchars
""
if exists("g:loaded_EscapeBchars") && g:loaded_EscapeBchars == 1
	finish
endif
""
let g:loaded_EscapeBchars = 1
let g:EscapeBchars_version = 0.4
""
function EscapeBchars( char, ... )
	let l:ComEsc = a:char
	let l:ComEsc = substitute( l:ComEsc, "\"", "\\\\\"", "g" )
	let l:ComEsc = substitute( l:ComEsc, "\/", "\\\\/", "g" )
	let l:ComEsc = substitute( l:ComEsc, "\*", "\\\\*", "g" )
	if a:0 > 0 && a:1 != ""
		let l:More = a:1
		let l:MoreEsc = l:More
		let l:MoreEsc = substitute( l:MoreEsc, "\"", "\\\\\"", "g" )
		let l:MoreEsc = substitute( l:MoreEsc, "\/", "\\\\/", "g" )
		let l:MoreEsc = substitute( l:MoreEsc, "\*", "\\\\*", "g" )
		if a:0 == 1
			let l:ComEsc = l:ComEsc . l:MoreEsc . "*"
		else
			if a:2 == 1
				let l:ComEsc = l:ComEsc . l:MoreEsc . "*"
			elseif a:2 == 2
				let l:ComEsc = l:ComEsc . "[^" . l:More . "]"
			elseif a:2 == 3
				let l:ComEsc = l:ComEsc . "\\(" . l:MoreEsc . "*"
			elseif a:2 == 4
				let l:ComEsc = l:ComEsc . "\\([^" . l:More . "]"
			elseif a:2 == -1
				let l:ComEsc = l:MoreEsc . "*" . l:ComEsc
			elseif a:2 == -2
				let l:ComEsc = "[^" . l:More . "]" . l:ComEsc
			elseif a:2 == -3
				let l:ComEsc = l:MoreEsc . "*\\)" . l:ComEsc
			elseif a:2 == -4
				let l:ComEsc = "[^" . l:More . "]\\)" . l:ComEsc
			else
				echoerr " EscapeBchars: a:2 value " . a:2 . " not accepted..."
			endif
		endif
	endif
	return l:ComEsc
endfunction
