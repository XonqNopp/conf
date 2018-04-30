"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Header function, that adds the heads requiered for .tex files
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Standard use: call Header( "class", "babellang", "title" )
"
if exists("g:TexHeader_loaded") && g:TexHeader_loaded == 1
	finish
endif

let g:TexHeader_loaded = 1

function! Header(...)
	let l:basename = expand("%:t:r")
	if a:0 > 1 && a:2 == "fr"
		setlocal spelllang=fr
		execute "setlocal spellfile=$vash/vim/spell/fr.latin1.add"
	endif
	set nocindent
	"" Writing
	if a:0 == 0
		let l:documentclass = "\[12pt,twoside,a4paper\]\{article\}"
	else
		if a:1 == ""
			let l:documentclass = "\[12pt,twoside,a4paper\]\{article\}"
		elseif a:1 == "lettre"
			split default.ins
			write
			quit
			let l:documentclass = "\[romand,12pt,a4paper\]\{lettre\}"
		elseif a:1 == "a0poster"
			let l:documentclass = "\[portrait,a0b,final\]\{a0poster\}"
		else
			let l:documentclass = "\[12pt,twoside,a4paper\]\{" . a:1 . "\}"
		endif
	endif
	let l:documentclass = "\\documentclass" . l:documentclass . "\n\%\%"
	if a:0 > 0 && a:1 == "beamer"
		"" Base tex files
		execute ":split " . l:basename . "_all.tex"
		execute "0read $vash/vim/templates/beamer_all.tex"
		execute "normal Gddgg"
		write
		quit
		execute ":split " . l:basename . "_slides.tex"
		execute "0read $vash/vim/templates/beamer_slides.tex"
		execute "normal Gddgg"
		write
		quit
		execute ":split " . l:basename . "_notes.tex"
		execute "0read $vash/vim/templates/beamer_notes.tex"
		execute "normal Gddgg"
		write
		quit
		"" Base lapd files
		execute ":split " . l:basename . "_all.lapd"
		execute "0read $vash/vim/templates/beamer_all.lapd"
		execute "normal Gddgg"
		write
		quit
		execute ":split " . l:basename . "_slides.lapd"
		execute "0read $vash/vim/templates/beamer_slides.lapd"
		execute "normal Gddgg"
		write
		quit
		execute ":split " . l:basename . "_notes.lapd"
		execute "0read $vash/vim/templates/beamer_notes.lapd"
		execute "normal Gddgg"
		write
		quit
		split header.tex
	else
		execute "normal GA\%\%\n\%\% Headers \%\%\% \{\{\{"
		execute "normal Go" . l:documentclass
	endif

	execute "$read $vash/vim/templates/variables.tex"
	if a:0 == 0 || ( a:0 > 0 && a:1 != "lettre" )
		execute "$read $vash/vim/templates/usepackages.tex"
		"" hypersetup
		if a:0 > 0 && a:1 == "a0poster"
			execute "normal Go\\usepackage\{pstricks,pst-grad\}"
		endif
		if a:0 > 0 && a:1 == "beamer"
			execute "$read $vash/vim/templates/beamer_headplus.tex"
		else
			execute "$read $vash/vim/templates/docsize.tex"
			execute "$read $vash/vim/templates/fancy.tex"
		endif
		execute "$read $vash/vim/templates/picpos.tex"
		execute "$read $vash/vim/templates/newcommands.tex"
		execute "$read $vash/vim/templates/endhead.tex"
		execute "$read $vash/vim/templates/titleinfo.tex"
	else
		execute "normal Go\\usepackage{mailing}\n\\usepackage\[french,english\]\{babel\}"
	endif
	if a:0 > 0 && a:1 == "beamer"
		"" Here are we in header.tex (beamer-only)
		write
		quit
		split main.tex
		execute "normal $read $vash/vim/templates/beamer_body.tex"
		execute "normal ggdd"
		write
		execute "wincmd w"
		quit
		"" We close the useless filename.tex file
	else
		execute "normal Go\%\%\n\%\% \}\}\}\n\%\%\n\\begin\{document\}"
	endif
	if a:0 == 0 || ( a:0 > 0 && ( a:1 != "beamer" && a:1 != "a0poster" && a:1 != "lettre" ) )
		execute "$read $vash/vim/templates/title.tex"
		execute "normal Go\%\%\n\n\%\%"
		execute "$read $vash/vim/templates/bib.tex"
		execute "normal Go\%\%"
		execute "$read $vash/vim/templates/app.tex"
	else
		if a:1 == "a0poster"
			execute "$read $vash/vim/templates/poster_body.tex"
		elseif a:1 == "lettre"
			execute "$read $vash/vim/templates/lettre_body.tex"
		endif
	endif
	if a:0 == 0 || a:1 != "beamer"
		execute "normal Go\%\%\n\\end\{document\}\n\%\%"
	endif
"" Er.....................................
	if a:0 > 0 && a:1 == "lettre"
		"" Next line should be improved...
		execute "normal 14Gddk"
		execute "13read $vash/vim/templates/lettre_head.tex"
	endif
"" End of writing
	set cindent
	execute "normal zM"
	execute "normal gg"
endfunction
"
