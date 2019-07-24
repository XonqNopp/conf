" This is MapComments plugin to have F5 and F6
" (un)commenting for each filetype

"" Comments philosophy:
"" "" This is a comment (help or doc text, not intended to ever be uncommented)
"" "This is a commented line (code)
""
"" TODO:
"" Change to use only one comchar with space as comment
""
"" Must be careful with b:chars if strlen > 1, this changes the pattern
"" add case when only start and stop (css html xml) in uncomment commentv uncommentv
"" Think about position restoring???
"" change do_proceed to regexp tests
"" Finish help files (also comchars)
"" put escapebchars OK, hgci OK, mapcomments and foldimproved on vim.org
"" Once uploaded, add GLVS numbers
"" If ComChar.ComCharMore__+__.( ): do not touch it
"" Problem with empty lines and single-ComChar lines
""
""
"" If ! exists("b:ComChar") && exists("b:ComCharStart") && exists("b:ComCharStop") && a:firstline != a:lastline
""   put b:ComCharStart before beginning
""   put b:ComCharStop after end
"" else
""  comment each line
"" endif
""
"" Uncomment will be more tough (check for the b:More to prevent uncommenting real comments)
""
"" Check vim tips "commenting out a range of lines" for real comments (http://vim.wikia.com/wiki/Commenting_out_a_range_of_lines)
""
"" Problems:
""  When using visual with a fold part, bug and do the commenting as many as there are lines
""  Problem with tab at ^
""  Cannot comment out an empty line
""
""

"" The following is not used by FoldImproved, thus is only defined here instead of in EscapeBchars
"" SetComChars {{{
function! SetComChars()
	if !exists("b:ComChar") && !exists("b:ComCharStart") && !exists("b:ComCharStop")
		let b:ComChar = "#"
	endif
	if exists("b:ComCharStart")
		if strlen(b:ComCharStart) > 0
			let s:LStart = strlen(b:ComCharStart) - 1
			let b:ComCharStartMore = b:ComCharStart[s:LStart]
		else
			unlet b:ComCharStart
		endif
	endif
	if exists("b:ComCharStop")
		if strlen(b:ComCharStop) > 0
			let b:ComCharStopMore = b:ComCharStop[0]
		else
			unlet b:ComCharStop
		endif
	endif
endfunction
"" }}}
"" We need to define this ReadPost because ftplugin are read after this file
autocmd BufReadPost,BufNewFile * call SetComChars()

"" g:vars {{{
if exists("g:loaded_MapComments") && g:loaded_MapComments == 1
	"finish"""""""""""""""""" MUST FIX THIS LINE WHEN OK
endif

let g:loaded_MapComments = 1
let g:MapComments_version = 0.2
if !exists("g:MapComment_key")
	let g:MapComment_key = "<F5>"
endif
if !exists("g:MapUnComment_key")
	let g:MapUnComment_key = "<F6>"
endif
if !exists("g:MapComment_at_beginning")
	let g:MapComment_at_beginning = 0
endif
if !exists("g:MapJoin_key")
	let g:MapJoin_key = "J"
endif
"" }}}

"" MapComment {{{
function! MapComment() range
	"" Put b:ComChar at the very(&user) beginning(&foldmethod) of the line except if the first non-blank chars are exactly "## "
	""
	"" Must first choose whether I use comchar or comcharstart-stop
	"" Select if using single char at beginning or pair at beginning and end "" {{{
	let l:choice = "single"
	if !exists("b:ComChar") && exists("b:ComCharStart") && exists("b:ComCharStop")
		let l:choice = "couple"
	endif
	if l:choice == "single" && !exists("b:ComChar")
		echoerr " MapComments: you should define b:ComChar or (b:ComCharStart and b:ComCharStop) !"
		return
	endif
	"" }}}
	"" Getting current position for future restoring
	let l:pos = getpos(".")
	let l:cur_line = l:pos[1]
	let cur_proceed = 0
	let l:ComCheck = ""
	let l:ComBeginCheck = ""
	let l:go_line = a:firstline - 1
	"" Preparing stuff with ComChar {{{
	if exists("b:ComChar")
		let l:ComCharEscaped = EscapeBchars(b:ComChar)
		let l:ComCharUnEscaped = b:ComChar
		let l:ComBeginCheckSingle = "^\\s*" . l:ComCharEscaped
			""        /^(\s*)(##?[^ ]|#[^# ]|[^#\s])/ ???
		let l:ComCheckSingle = "^\\(\\s*\\)\\(" . l:ComCharEscaped . l:ComCharEscaped . "\\?[^ ]\\|" . l:ComCharEscaped . "[^" . l:ComCharUnEscaped . " ]\\|[^" . l:ComCharUnEscaped . "\\t ]\\)"
	endif
	"" }}}
	"" Preparing stuff with ComCharStart and ComCharStop {{{
	if exists("b:ComCharStart") && exists("b:ComCharStop")
		"" /^(\s)((/*[^*]|/[^*]).*([^*]*/|[^*]/))/
		"" /^(\s)((<!--[^-]|<!-[^-]).*([^-]-->|[^-]->))/
		"" Or maybe I have to check what is in the line then perform a simple substitute?
		"" I can use the =~# regexp match case op
		""
		"" The trick is I want to do a simple substitution but only if a
		"" complicated string is matched. Thus I can define the string as
		"" /^(\s*)([^\s].*)/ here and later do the checks, which will depend
		"" upon the choice we are using (change do_proceed -> check)
		""
		"" Now I am trying to use a universal comstring and to prepare
		"" a comcheck here which will work in a single check
		let l:ComCharStartEscaped = EscapeBchars(b:ComCharStart)
		let l:ComCharStartUnEscaped = b:ComCharStart
		let l:ComCharStopEscaped = EscapeBchars(b:ComCharStop)
		let l:ComCharStopUnEscaped = b:ComCharStop
		let l:ComCharStartPat = EscapeBchars(b:ComCharStart, b:ComCharStartMore, 2)
		let l:ComCharStopPat = EscapeBchars(b:ComCharStop, b:ComCharStopMore, -2)
		let l:ComCheckCouple = "^\\(\\s*\\)"
		"" Wait... what I want is it matches my pat ONLY if it is already a comment...
		"" I think I cannot do these two checks together...
		let l:ComCheckCouple .= l:ComCharStartPat
		let l:ComCheckCouple .= ".\\{-}"
		let l:ComCheckCouple .= l:ComCharStopPat
		let l:ComBeginCheckCouple = "^\\s*" . l:ComCharStartEscaped
	endif
	"" }}}
	"" Looping through the lines and treat them "" {{{
	"" s/^(\s*)((#((#([^ ]|$)|[^#])|$)|[^#])|$)/#\1\3/g
	while l:go_line < a:lastline
		let l:go_line += 1
		let l:SpaceGroup = 1
		let l:TextGroup = 2
		let l:string = l:go_line . "s/^"
		if match(getline(l:go_line),"^\\s") != -1
			let l:string .= "\\(\\s\\+\\)"
		else
			let l:SpaceGroup = -1
			let l:TextGroup = 1
		endif
		"if l:choice == "single"
		let l:string .= "\\([^ \\t].*\\)"
		"echomsg l:ComCheck
		let l:the_line = getline(l:go_line)
		"" If ComChar, check ComBeginCheckSingle
		"" If ComCharStart/Stop, check ComBeginCheckCouple
		let l:Proceed = 0
		if exists("b:ComChar") && exists("b:ComCharStart") && exists("b:ComCharStop")
			if (l:the_line !~# l:ComBeginCheckSingle || (l:the_line =~# l:ComBeginCheckSingle && l:the_line =~# l:ComCheckSingle)) && (l:the_line !~# l:ComBeginCheckCouple || (l:the_line =~# l:ComBeginCheckCouple && l:the_line =~# l:ComCheckCouple))
				let l:Proceed = 1
			endif
		elseif exists("b:ComChar")
			if l:the_line !~# l:ComBeginCheckSingle || (l:the_line =~# l:ComBeginCheckSingle && l:the_line =~# l:ComCheckSingle)
				let l:Proceed = 1
			endif
		else
			if l:the_line !~# l:ComBeginCheckCouple || (l:the_line =~# l:ComBeginCheckCouple && l:the_line =~# l:ComCheckCouple)
				let l:Proceed = 1
			endif
		endif
		"" If OK, proceed
		if l:Proceed
			if l:go_line == l:cur_line
				if l:choice == "single"
					let l:pos[2] = l:pos[2] + strlen(b:ComChar)
				else
					let l:pos[2] = l:pos[2] + strlen(b:ComCharStart)
				endif
			endif
			let l:string .= "/"
			if l:choice == "single"
				"" Treating single case "" {{{
				if l:SpaceGroup > 0
					if &foldmethod != "indent" && g:MapComment_at_beginning
						let l:string .= l:ComCharEscaped . "\\" . l:SpaceGroup
					else
						let l:string .= "\\" . l:SpaceGroup . l:ComCharEscaped
					endif
				else
					let l:string .= l:ComCharEscaped
				endif
				let l:string .= "\\" . l:TextGroup
				"" }}}
			else
				"" Treating couple case "" {{{
				if l:SpaceGroup > 0
					if &foldmethod != "indent" && g:MapComment_at_beginning
						let l:string .= l:ComCharStartEscaped . "\\" . l:SpaceGroup
					else
						let l:string .= "\\" . l:SpaceGroup . l:ComCharStartEscaped
					endif
				else
					let l:string .= l:ComCharStartEscaped
				endif
				let l:string .= "\\" . l:TextGroup
				let l:string .= l:ComCharStopEscaped
				"" }}}
			endif
			let l:string .= "/g"
			"echomsg l:string
			if l:the_line == ""
				"" Following should be tested with ComCharStart-Stop and tabs
				let l:string = substitute(l:string, "\/[^/]*\/", "\/^$\/", "")
				let l:string = substitute(l:string, "\\\\1", "", "")
			endif
			"echomsg l:string
			execute l:string
		endif
	endwhile
	"" }}}
	"" Restore the cursor position and shift it when needed "" {{{
	"if l:cur_proceed
		"call setpos(".", l:pos)
	"endif
	"" }}}
endfunction
"" }}}
"" MapUnComment {{{
"" Must redo all of it removing the More (they are just the normal exteneded...)
function! MapUnComment() range
	let l:choice = "single"
	if !exists("b:ComChar") && exists("b:ComCharStart") && exists("b:ComCharStop")
		let l:choice = "couple"
	elseif exists("b:ComChar") && exists("b:ComCharStart") && exists("b:ComCharStop")
		let l:choice = "both"
	endif
	if l:choice == "single" && !exists("b:ComChar")
		echoerr " MapComments: you should define b:ComChar or (b:ComCharStart and b:ComCharStop) !"
		return
	endif
	"" Escaping comchar {{{
	if exists("b:ComChar")
		"" Storing the normal ComChar
		let l:ComCharUnEscaped = b:ComChar
		"" Storing the escaped ComChar
		let l:ComCharEscaped = EscapeBchars(b:ComChar)
		"" Making test string
		let l:ComStringSingle = "^\\(\\s*\\)\\(" . l:ComCharEscaped . l:ComCharEscaped . "\\?[^ ]\\|" . l:ComCharEscaped . "[^" . l:ComCharUnEscaped . " ]\\|[^" . l:ComCharUnEscaped . "\\t ]\\)"
		"" Making substitution string
		let l:ComSubstSingle = "^\\(\\s*\\)" . l:ComCharEscaped . "\\(.*\\)$"
	endif
	"" }}}
	"" Escaping ComCharSt(art|op) {{{
	"" /^(\s)/*([^*].\{-}[^*])*//   where \{-} states for regexp *?
	if exists("b:ComCharStart") && exists("b:ComCharStop")
		let l:ComCharStartEscaped = EscapeBchars(b:ComCharStart)
		let l:ComCharStartUnEscaped = b:ComCharStart
		let l:ComCharStopEscaped = EscapeBchars(b:ComCharStop)
		let l:ComCharStopUnEscaped = b:ComCharStop
		let l:ComCharStartPat = EscapeBchars(b:ComCharStart, b:ComCharStartMore, 4)
		let l:ComCharStopPat = EscapeBchars(b:ComCharStop, b:ComCharStopMore, -4)
		let l:ComStringCouple = "^\\(\\s*\\)" . l:ComCharStartPat . ".\\{-}" . l:ComCharStopPat
		let l:ComSubstCouple = "^\\(\\s*\\)" . l:ComCharStartEscaped . "\\(.*\\)" . l:ComCharStopEscaped . "$"
	endif
	"" }}}
	let l:ComString = ""
	"" Must check *ALL* comchars and remove *ONLY ONE*...
	"" Always treat the char at the most left of the line
	if l:choice == "single" && exists("l:ComStringSingle")
		"" s/^(\s*)#(#[^ ]|[^#])/
		let l:ComString = l:ComStringSingle
		let l:ComSubst = l:ComSubstSingle
	elseif l:choice == "couple" && exists("l:ComStringCouple")
		let l:ComString = l:ComStringCouple
		let l:ComSubst = l:ComSubstCouple
	elseif l:choice == "both"
		"" This case must be treated line by line, thus moving it into the loop...
	endif
	let l:pos = getpos(".")
	let l:cur_line = l:pos[1]
	let l:cur_proceed = 0
	let l:go_line = a:firstline - 1
	while l:go_line < a:lastline
		let l:go_line = l:go_line + 1
		let l:thisline = getline(l:go_line)
		if l:choice == "both"
			"" If both, check which
			if l:thisline =~# l:ComStringSingle
				"" Remove b:ComChar
				let l:ComString = l:ComStringSingle
				let l:ComSubst = l:ComSubstSingle
			elseif l:thisline =~# l:ComStringCouple
				"" Remove b:ComCharStart/Stop
				let l:ComString = l:ComStringCouple
				let l:ComSubst = l:ComSubstCouple
			else
				"" Temporary error
				echoerr " No ComChar found on this line..."
				"" Skip to next in while loop
			endif
		endif
		"echoerr l:ComString
		if l:thisline =~# l:ComString
			let l:UnCom = "s/" . l:ComSubst . "/\\1\\2/"
			"echomsg l:UnCom
			execute l:UnCom
		endif
		let l:string = l:go_line . "s/"
		let l:string .= l:ComString
		let l:string .= "/"
		let l:string .= "\\1\\2"
		let l:string .= "/g"
		"if l:do_proceed
			if l:go_line == l:cur_line
				if l:choice == "single" || l:choice == "both_single"
					let l:pos[2] = l:pos[2] - strlen(b:ComChar)
				else
					let l:pos[2] = l:pos[2] - strlen(b:ComCharStart)
				endif
			endif
			"execute l:string
		"endif
	endwhile
	"if l:cur_proceed
		"call setpos(".", l:pos)
	"endif
	"" This depends upon the mode and what we did.
endfunction
"" }}}
"" MapCommentVisual {{{
function! MapCommentV() range
	let l:pos = getpos(".")
	""""" THIS FUNCTION IS ONLY CALLED IN VISUAL MODE '''''
	"" If visual line or block, can put start and stop on single lines before and after
	""   else (visual) have to put at '< and '> except if start and stop not defined
	"" If single line and no start/stop defined, check if col("'>") == $
	"if exists("b:ComCharStart") && exists("b:ComCharStop") && (a:lastline != a:firstline || !exists("b:ComChar"))
		"" How to get this case when visual within a single line??
		""let l:ComCharStartPat = EscapeBchars(b:ComCharStart, b:ComCharStartMore, 1)
		""let l:ComCharStopPat = EscapeBchars(b:ComCharStop, b:ComCharStopMore, -1)
		"" Better use the following, but prevent commenting real comments (those with the b:More)
		"let l:ComCharStartPat = EscapeBchars(b:ComCharStart)
		"let l:ComCharStopPat = EscapeBchars(b:ComCharStop)
		"if a:lastline == a:firstline
			"" Single line
			"echomsg "  The last visual mode used was --" . visualmode() . "--"
			"" visualmode() =~# "^v" can be a single inline
			"" others must be whole lines (cannot comment out a visual block)
			""
			"" Try to check with mode() (v/V/CTRL-V)
			"" mode() =~# "^[vV\<C-v>]"
			"" mode() =~# "^v"
			"if line("'<") == line("'>") && line("'<") == a:firstline
				"" Visual on single line
			"else
				"" Whole line to comment out
			"endif
		"else
			"" Multiple lines
		"endif
	"else
		execute a:firstline . "," . a:lastline . "call MapComment()"
	"endif
	"call setpos(".", l:pos)
	"" Not if called MapComment
	"" This depends upon the mode and what we did.
	"" For instance, if we add a line, we have to go one line further.
endfunction
"" }}}
"" MapUnCommentVisual {{{
function! MapUnCommentV() range
	let l:pos = getpos(".")
	"" Must be changed...
	execute a:firstline . "," a:lastline . "call MapUnComment()"
	"call setpos(".", l:pos)
	"" Not if called MapUnComment
	"" This depends upon the mode and what we did.
	"" For instance, if we add a line, we have to go one line further.
endfunction
"" }}}

"" mapping stuff {{{
execute "silent! unmap  " . g:MapComment_key
execute "silent! unmap  " . g:MapUnComment_key
execute "silent! nunmap " . g:MapComment_key
execute "silent! nunmap " . g:MapUnComment_key
execute "silent! vunmap " . g:MapComment_key
execute "silent! vunmap " . g:MapUnComment_key
"" Not necessary??
execute "silent! unmap  <buffer>" . g:MapComment_key
execute "silent! unmap  <buffer>" . g:MapUnComment_key
execute "silent! nunmap <buffer>" . g:MapComment_key
execute "silent! nunmap <buffer>" . g:MapUnComment_key
execute "silent! vunmap <buffer>" . g:MapComment_key
execute "silent! vunmap <buffer>" . g:MapUnComment_key
"" Maps normal and visual silently (absolutely)
"execute "nmap <silent> " . g:MapComment_key . " :silent call MapComment()<cr>"
execute "nmap <silent> " . g:MapComment_key . " :call MapComment()<cr>"
"execute "nmap <silent> " . g:MapUnComment_key . " :silent call MapUnComment()<cr>"
execute "nmap <silent> " . g:MapUnComment_key . " :call MapUnComment()<cr>"
"execute "vmap <silent> " . g:MapComment_key . " :<C-u>silent '<,'>call MapCommentV()<cr>"
execute "vmap <silent> " . g:MapComment_key . " :<C-u>'<,'>call MapCommentV()<cr>"
execute "vmap <silent> " . g:MapUnComment_key . " :<C-u>silent '<,'>call MapUnCommentV()<cr>"
""execute "vmap <silent> " . g:MapComment_key . " :<C-u>silent <line1>,<line2>call MapCommentV()<cr>"
"execute "vmap <silent> " . g:MapComment_key . " :<C-u><line1>,<line2>call MapCommentV()<cr>"
"execute "vmap <silent> " . g:MapUnComment_key . " :<C-u>silent <line1>,<line2>call MapUnCommentV()<cr>"
"" }}}

"" join {{{
"" Trying to implement also Vim tips ''Remap join to merge comment lines'' (see wiki)
function! MapJoin() range
	"" check if each line begins with a comchar
	execute a:firstline . "," . a:lastline . "join"
endfunction

"execute "nmap <silent> " . g:MapJoin_key . " :silent call MapJoin()<cr>"
"execute "vmap <silent> " . g:MapJoin_key . " :silent call MapJoin()<cr>"
"" }}}
