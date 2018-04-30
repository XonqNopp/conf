""""""""""""""""""""""""""""""""""""""""""""""""""""
""  Plugin written and maintained by Gael Induni
"" This is FoldImproved plugin to have a nice fold text
""   (especially removing my LaTeX headers)
""  Last modified: Mon 2015-08-31 09:42:47 CEST
""  Version 0.1
""""""""""""""""""""""""""""""""""""""""""""""""""""
""
""
"" When performing, put it on vim.org with MapComments (change keys to be variables to enable other to change them)
""
""
if exists("g:loaded_FIm") && g:loaded_FIm
	finish
endif
let g:loaded_FIm = 1
let g:FIm_version = 0.1
""
""
""
let s:FoldImprovedEnable = 1
if (exists("g:FoldImprovedEnable") && !g:FoldImprovedEnable) || (exists("b:FoldImprovedEnable") && !b:FoldImprovedEnable)
	let s:FoldImprovedEnable = 0
endif

function FoldImproved()
	"" set variables
	let l:leftstr   = ""
	let l:middlestr = ""
	let l:rightstr  = ""
	let l:minlen    = 2
	let l:padchar   = "-"
	"" Getting info
	let l:foldedlines   = v:foldend - v:foldstart + 1
	let l:textwidth     = winwidth(0) - &foldcolumn - (&number ? &numberwidth : 0)
	let l:halfwidth     = ceil(l:textwidth/2.0)
	let l:totallines    = line("$")
	let l:foldedpercent = printf("%2.0f", 100.0 * l:foldedlines / l:totallines) . "%"
	let l:FL            = "FL" . string(v:foldlevel)
	""
		"" Get name
		let l:name = getline(v:foldstart)
		"" Python check
		if match(l:name, '^ *"""$') > -1
			let l:name = getline(v:foldstart+1)
		endif
		"" Erase the fold marks
		let l:name = substitute(l:name, '\( \|\t\)*{{{[0-9]*\( \|\t\)*', "", "")
		let l:originalname = l:name
		"" Closing not necessary because not on the same line
		""
		"" Erase the latex position comments
		let l:name = substitute(l:name, '%\+ \+\(chapter\|section\|sub\(-sub\)\?\|\(sub-\)*paragraph\) \+%\+ *', "", "i")
		let l:name = substitute(l:name, '^%\?\s*\\begin{[^}]\+}%%\(.*\)$', '\1', "i")
		let l:name = substitute(l:name, '^%\?\s*\\begin{[^}]\+}{\([^}]\+\)}.*$', '\1', "i")
		let l:name = substitute(l:name, '^%\?\s*\\begin{frame}%\?{\?\(#&%}\)\?', "", "i")
		let l:name = substitute(l:name, '^%\?\s*\\[A-Za-z]\+\*\?\(\[[^\]]\+\]\)\?{', "", "i")
		let l:name = substitute(l:name, '\\label{[^}]*}\s*', "", "i")
		let l:name = substitute(l:name, '\\item\(\[[^\]]*\]\)\? *', "", "")
		let l:name = substitute(l:name, '}.*%', "", "")
		"" Erase comment chars (using b: vars)
			"" Prepare comment chars to be escaped
			"" Characters to escape: / * "
				"" ComChar
				if exists("b:ComChar")
					let l:ComCharEscaped = EscapeBchars(b:ComChar)
					let l:ComCharEscaped = "^\\s*" . l:ComCharEscaped . "\\+\\s*"
				endif
			""
				"" ComCharStartPat
				if exists("b:ComCharStart")
					if exists("b:ComCharStartMore")
						let l:ComCharStartPat = EscapeBchars(b:ComCharStart, b:ComCharStartMore, 1)
					else
						let l:ComCharStartPat = EscapeBchars(b:ComCharStart)
					endif
					let l:ComCharStartPat = "\\s*" . l:ComCharStartPat . "\\+\\s*"
				endif
			""
				"" ComCharStopPat
				if exists("b:ComCharStop")
					if exists("b:ComCharStopMore")
						let l:ComCharStopPat = EscapeBchars(b:ComCharStop, b:ComCharStopMore, -1)
					else
						let l:ComCharStopPat = EscapeBchars(b:ComCharStop)
					endif
					let l:ComCharStopPat = "\\s*" . l:ComCharStopPat . "\\+\\s*"
				endif
			""
				"" Remove them from the string
				if exists("l:ComCharEscaped")
					let l:name = substitute(l:name, l:ComCharEscaped, "", "g")
				endif
				if exists("l:ComCharStartPat")
					let l:name = substitute(l:name, l:ComCharStartPat, "", "g")
				endif
				if exists("l:ComCharStopPat")
					let l:name = substitute(l:name, l:ComCharStopPat, "", "g")
				endif
		""
		"" Remove python docstring char
		let l:name = substitute(l:name, ' *""" *', "", "g")
		"" Change tabs to space to remove superflu
		let l:name = substitute(l:name, '\t\+', "    ", "")
		"" Erase spaces at beginning and end of line
		let l:name = substitute(l:name, ' \+$', "", "")
		let l:name = substitute(l:name, '^ \+', "", "")
		""
		"" check if comment says disabled
		if matchstr(l:name, '(DISABLED)') != ""
			"echomsg l:name
			let l:name = substitute(l:name, ' *(DISABLED)', "", "")
			let l:name = "  [---" . l:name . "---]  "
			"let l:padchar = "':"
			let l:padchar = "'"
		endif
		""
		if l:name == ""
			if l:originalname == ""
				let l:name = "## no title for this fold ##"
			else
				let l:name = l:originalname
			endif
		endif
	""
		"" set left, middle and right text
			"" left
			let l:leftstr  = ""
			let l:leftstr .= "to "
			let l:leftstr .= printf("%3.0f", v:foldend)
			let l:leftstr .= "  ("
			let l:leftstr .= printf("%3.0f", l:foldedlines) . "l"
			let l:leftstr .= "="
			let l:leftstr .= l:foldedpercent
			let l:leftstr .= ") "
			let l:leftstr .= l:FL
			let l:leftstr .= " "
		""
			"" middle
			let l:middlestr  = ""
			let l:middlestr .= " "
			let l:middlestr .= l:name
			let l:middlestr .= " "
		""
			"" right
			let l:rightstr  = ""
			"let l:rightstr .= " "
			let l:rightstr .= v:folddashes
			let l:rightstr .= "\+"
	""
		"" remove garbage if string too long
		let delta = strwidth(l:middlestr) - (l:textwidth - strwidth(l:leftstr.l:rightstr) - 2*l:minlen) + 1
		if delta > 0
			let delta = delta+4
			"" reduce name and make it end by ...
			let l:middlestr = l:middlestr[:-delta] . "... "
		endif
	""
		"" compute lengths
		let l:explen    = max([l:textwidth - strwidth(l:leftstr.l:rightstr), 3])
		let l:expansion = repeat(l:padchar, l:explen)
		""
		let l:expleftlen  = max([float2nr(l:halfwidth - (strwidth(l:leftstr) + floor(strwidth(l:middlestr)/2.0))),l:minlen])
		let l:exprightlen = l:textwidth - (l:expleftlen + strwidth(l:leftstr.l:middlestr.l:rightstr))
		while l:exprightlen < l:expleftlen && l:expleftlen > l:minlen
			"echomsg "left=" . l:expleftlen . "; right=" . l:exprightlen
			let l:expleftlen = l:expleftlen - 1
			let l:exprightlen = l:textwidth - (l:expleftlen + strwidth(l:leftstr.l:middlestr.l:rightstr))
		endwhile
		let l:odd = 1
		while l:expleftlen + l:exprightlen + strwidth(l:leftstr.l:middlestr.l:rightstr) > l:textwidth
			if l:odd
				let l:exprightlen -= 1
				let l:odd = 0
			else
				let l:expleftlen -= 1
				let l:odd = 1
			end
		endwhile
		""
		"echomsg "left=" . l:expleftlen . "; right=" . l:exprightlen
		let l:expleft  = repeat(l:padchar, l:expleftlen)
		let l:expright = repeat(l:padchar, l:exprightlen)
	""
		"" send back final string
		let l:back = l:leftstr
		if l:middlestr == ""
			let l:back .= l:expansion . l:rightstr
		else
			let l:back .= l:expleft . l:middlestr . l:expright . l:rightstr
		endif
	return l:back
endfunction


if s:FoldImprovedEnable
	if (exists("g:FoldImprovedLocal") && g:FoldImprovedLocal) || (exists("b:FoldImprovedLocal") && b:FoldImprovedLocal)
		setlocal foldtext=FoldImproved()
	else
		set foldtext=FoldImproved()
	endif
endif


"" vim: foldmethod=indent:
