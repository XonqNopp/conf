" This script makes a better statusline

if exists('g:loaded_SLIm') && g:loaded_SLIm
	finish
endif
let g:loaded_SLIm = 1
let g:SLIm_version = 0.0


function StatusLineImproved()
	let l:name     = '%f'
	"let l:GitBranch = substitute(system('git branch --color=never 2> /dev/null | sed -e '/^[^*]/d' -e 's/* //''), '\n', '', 'g')
	"if l:GitBranch != ''
		"let l:GitBranch = '<git:' . l:GitBranch . '>  '
	"endif
	let l:mod_tag  = '%m'
	let l:ro_tag   = '%r'
	let l:help_tag = '%h'
	let l:hfill    = '%='
	let l:linecol  = '%l,%c'
	let l:perce    = '%5P'
	let l:time     = '%7{strftime("%H:%M")}'
	" build:
	let l:leftstr  = ''
	let l:rightstr = ''

	let l:leftstr .= l:name
	let l:leftstr .= ' '
	let l:leftstr .= l:mod_tag
	let l:leftstr .= l:ro_tag
	let l:leftstr .= l:help_tag

	"let l:rightstr .= l:GitBranch
	let l:rightstr .= l:linecol
	let l:rightstr .= l:perce
	let l:rightstr .= l:time
	" build back
	let l:back = ' ' . l:leftstr . l:hfill . l:rightstr . '  '

	return l:back
endfunction

"" always show the status line
set laststatus=2
"" set it to be the one built above
set statusline=%!StatusLineImproved()
