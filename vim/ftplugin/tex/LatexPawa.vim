""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""   Vim script written and maintained by Gael Induni
"" This script run the LaTeXPawa perl script and display
""  an error message when needed.
"" The function call is mapped to F1
"" Created      : long ago
"" Last modified: Fri 2014-09-05 08:08:09 CEST
"" Version 0.01
"" GetLatestVimSciprts: 0000 1 :AutoInstall: #&%
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""
if exists("g:loaded_LatexPawa") && g:loaded_LatexPawa
	finish
endif
let g:loaded_LatexPawa = 1

let g:LatexPawa_version = 0.1

if exists("g:HSH") && g:HSH != ""
	let g:LatexPawa_perl_path = g:vash . "/perl"
else
	let g:LatexPawa_perl_path = "."
endif
""
function LatexPawa(...)
	"" First we save
	write
	"" We set the run command
	let l:oister = "perl"
	if !has("perl")
		let l:oister = "!" . l:oister
	endif
	"let l:oister = "silent " . l:oister
	let l:oister .= " "
	"" Then we can run LaTeXPawa
	if a:0 > 0
		for i in range(1,a:0)
			let l:fn = eval("a:" . i)
			execute l:oister . g:LatexPawa_perl_path . "/latexpawa.pl " . l:fn
			if v:shell_error
				call s:LatexPawaError(l:fn)
				break
			endif
		endfor
	else
		let l:fn = expand("%")
		execute l:oister . g:LatexPawa_perl_path . "/latexpawa.pl " . l:fn
		if v:shell_error
			call s:LatexPawaError(l:fn)
		endif
	endif
endfunction
""
""
"" Mapping the call of the LaTeXpawa function to F1:
map <buffer> <F1> :call LatexPawa()<cr><cr>
""
""
""
function s:LatexPawaError(fn)
	let l:plg = substitute(a:fn,".tex","","")
	let l:plg = l:plg . ".plg"
	let l:plg = ".texst/" . l:plg
	execute "10split " . l:plg
	execute "normal G"
	let l:plg_last = getline(".")
	execute "quit"
	echoerr " Problem running LaTeXPawa..."
	echohl Error
	echomsg "  Last line of log (" . l:plg . "):"
	echomsg "  " . l:plg_last
	echohl None
endfunction
