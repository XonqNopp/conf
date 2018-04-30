""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""   Vim script written and maintained by Gael Induni
""   Inspired from the VIm documentation and JonSkanes on
""   http://vim.wikia.com/wiki/Show_tab_number_in_your_tab_line
"" This script makes a better tabline
"" Created      : Wed 2013-09-11 08:35:02 CEST
"" Last modified: Thu 2015-04-02 07:35:38 CEST
"" Version 0.0
"" GetLatestVimSciprts: 0000 1 :AutoInstall: #&%
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("g:loaded_TLIm") && g:loaded_TLIm
	finish
endif
let g:loaded_TLIm = 1
let g:TLIm_version = 0.0


function TLImTabLine()
	"" do not start at the very left of the line:
	let l:back = repeat(" ", (&number ? &numberwidth : 0)+&foldcolumn)
	"" counter for buffers
	let l:counter = 0
	"" loop on tabs
	for i in range(tabpagenr("$"))
		"" count buffer
		let l:counter += tabpagewinnr(i+1, "$")
		"" select the highlighting
		if i+1 == tabpagenr()
		  let l:back .= "%#TabLineSel#"
		else
		  let l:back .= "%#TabLine#"
		endif

		"" set the tab page number (for mouse clicks)
		let l:back .= "%" . (i+1) . "T"

		"" the label is made by MyTabLabel()
		let l:back .= " %{TLImLabel(" . (i+1) . ")} "
	endfor

	"" after the last tab fill with TabLineFill and reset tab page nr
	let l:back .= "%#TabLineFill#%T"

	"" right-align the label to close the current tab page
	"if tabpagenr("$") > 1
		"let l:back .= "%=%#TabLine#%999Xclose"
	"endif
	if l:counter > tabpagenr("$")
		let l:back .= "%=%#TabLine#"
		let l:back .= l:counter
		"let l:back .= "|"
		let l:back .= "@"
		let l:back .= tabpagenr("$")
	elseif l:counter == tabpagenr("$") && l:counter > 1
		let l:back .= "%=%#TabLine#"
		let l:back .= printf("%2.0f", l:counter)
	endif

	return l:back
endfunction

function TLImLabel(n)
	let l:buflist = tabpagebuflist(a:n)
	let l:winnr = tabpagewinnr(a:n)
	let l:curbuf = l:buflist[l:winnr-1]
	let l:bufnumber = tabpagewinnr(a:n, "$")
	for bufIndex in l:buflist
		if match(bufname(bufIndex), "NERD_tree") == 0 && l:bufnumber > 1 && bufIndex != l:curbuf
			let l:bufnumber -= 1
		endif
	endfor
	let l:tabnumber = tabpagenr("$")
	let l:back = ""
	"" tab number if more than one
	if l:tabnumber > 1
		let l:back .= string(a:n) . ": "
		"let l:back .= string(a:n) . "/" . tabpagenr("$") . ": "
	endif
	""" tab current filename
	let l:bufname = fnamemodify(bufname(l:curbuf), ":t")
	""" if help file, remove extension and add [H] tag or check if readonly
	if getbufvar(l:curbuf, "&buftype") == "help"
		let l:bufname = fnamemodify(l:bufname, ":s/.txt$//") . " [H]"
	elseif getbufvar(l:curbuf, "&readonly") == 1
		let l:bufname .= " [RO]"
	endif
	if l:bufname == ""
		"let l:bufname = "untitled" . string(l:curbuf)
		let l:bufname = "[No Name]"
	endif
	let l:back .= l:bufname
	"" buffer number in tab if more than one
	if l:bufnumber > 1
		let l:back .= " " . string(l:winnr) . "/" . string(l:bufnumber)
	endif
	"" loop through each buffer in a tab, check and ++ tab's &modified count
	let l:modified = 0
	for b in tabpagebuflist(a:n)
		let l:modified += getbufvar(b, "&modified")
	endfor
	"" add modified label [+]
	if l:modified > 0
		let l:back .= " ["
		let l:back .= "+"
		"" if(
		""   more than one buffer in all tabs
		"" and
		""   (
		""     more than one modified buffer in this tab
		""   or
		""     (
		""       not in the tab with the modified buffer
		""     or
		""       in the tab but not in the modified buffer
		""     )
		""  )
		"" )
		if l:bufnumber > 1 && (l:modified > 1 || (a:n != tabpagenr() || !getbufvar(l:curbuf, "&modified")))
			let l:back .= l:modified
		endif
		let l:back .= "]"
		""
		"let l:back .= " [" . repeat("+", l:modified) . "]"
	endif
	return l:back
endfunction

"" always show tab line
set showtabline=2
"" set tabline to be the previous function
set tabline=%!TLImTabLine()
"" must change highlight to remove crappy underline
highlight TabLineSel  term=bold    cterm=bold    gui=bold    ctermfg=Yellow ctermbg=Blue
highlight clear TabLine
highlight TabLine term=reverse cterm=reverse gui=reverse
highligh TabLineFill term=reverse cterm=reverse gui=reverse
