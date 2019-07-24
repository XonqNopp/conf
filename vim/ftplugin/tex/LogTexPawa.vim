" Script written and maintained by XonqNopp
" This (v)splits to the log of latexpawa

if exists("g:loaded_LogTexPawa") && g:loaded_LogTexPawa
	finish
endif
let g:loaded_LogTexPawa = 1
let g:LogTexPawa_version = "0.1"
let g:LogTexPawa_path = ".texst/"
let g:LogTexPawa_ext = ".plg"
""
""
function LogTexPawa(...)
	if a:0 == 0
		let l:short = expand("%:t:r")
	else
		let l:short = a:1
		let l:short = substitute(l:short,"\.tex$","","")
	endif
	let l:log = g:LogTexPawa_path . l:short . g:LogTexPawa_ext
	if !filereadable(l:log)
		echoerr " Log file not found: " . l:log
		return
	endif
	execute "13split " . l:log
	execute "normal G"
endfunction
""
com! -nargs=* -complete=file LogTexPawa call LogTexPawa(<f-args>)
