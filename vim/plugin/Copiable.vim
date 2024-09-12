" This is the function called by F2 to make a vim file copiable by CTRL-c

if exists('g:loaded_Copiable') && g:loaded_Copiable
	finish
endif
let g:loaded_Copiable = 1
let g:Copiable_version = '0.1'

autocmd BufReadPre,BufNewFile * let b:IsCopiable = 0

function DoCopiable()
	setlocal invnumber
	setlocal invlinebreak
	if b:IsCopiable
		let b:IsCopiable = 0
		execute 'setlocal foldcolumn=' . b:OldFoldCol
		execute 'setlocal foldlevel=' . b:OldFoldLvl
		execute 'normal zv'
	else
		let b:IsCopiable = 1
		let b:OldFoldCol = &foldcolumn
		setlocal foldcolumn=0
		let b:OldFoldLvl = &foldlevel
		setlocal foldlevel=100
		execute 'normal zz'
	endif
endfunction

map <silent> <F2> :call DoCopiable()<cr>
