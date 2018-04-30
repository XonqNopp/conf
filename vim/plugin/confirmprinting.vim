"" Script written and maintained by G. Induni
"" Last modified: Tue 08 Feb 2011 08:23:00 AM CET
""

"" originally: printexpr=system('lpr' . (&printdevice == '' ? '' : ' -P' . &printdevice) . ' ' . v:fname_in) . delete(v:fname_in) + v:shell_error

if exists('g:confirmprinting')
	finish
endif

function! ConfirmPrinting()
	let l:printdev = &printdevice
	if l:printdev == ''
		let l:printdev = system('lpstat -d')
		let l:printdev = substitute(l:printdev,"\n","","")
		let l:printdev = substitute(l:printdev,"system default destination: ","","")
	endif
	"let l:filename = expand("%:p")
	let l:filename = expand("%")
	"let l:confirm = input('  Are you sure you want to print ' . l:filename . ' on ' . l:printdev . ' ??? [y/n]  ' )
	"if l:confirm == '' && ( l:confirm == 'y' || l:confirm == 'Y' )
	let l:confirm = confirm('  Are you sure you want to print ' . l:filename . ' on ' . l:printdev . ' ???',"&yes\n&no",2)
	if l:confirm == 1
		echo ' Printing...'
		"" Print command here
		return system('lpr' . ' -P' . l:printdev . ' ' . v:fname_in) . delete(v:fname_in) + v:shell_error
	else
		echoerr " User aborting !"
		return 1   " to prevent the global script going further
	endif
endfunction
