"syntax match texComment "%.*" contains=@NoSpell
autocmd BufReadPost * syntax match texComment "%.*" contains=@NoSpell
autocmd Syntax * syntax match texComment "%.*" contains=@NoSpell
""
if has("spell")
	"map <buffer> ;s viW"sy:spellgood getreg('s')<cr>
	" Marche pas :-(
	map <buffer> _w viW
	setlocal spell			" To check the spell
	" How to choose the language?
	setlocal spelllang=en
	"setlocal spelllang=fr
	"setlocal spelllang=en,fr
	if match(&spelllang,",") > -1
		execute "setlocal spellfile=$vash/vim/spell/en.utf-8.add"
	else
		execute "setlocal spellfile=$vash/vim/spell/" . &spelllang . ".utf-8.add"
	endif
	"autocmd BufReadPost * execute "setlocal spellfile=$vash/vim/spell/" . &spelllang . ".utf-8.add"
endif
autocmd BufReadPost *.log,*.sty,*.aux,*.toc setlocal nospell
