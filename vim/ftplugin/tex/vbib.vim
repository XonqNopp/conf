" Vertical split for bibliography of tex file
function! Vbib(dirchange,...)
	if a:0 > 0
		if !empty(a:1) && a:1 != '0'
			let l:fn = a:1
		else
			let l:fn = @%
		endif
		let l:fn = substitute( l:fn, "\.tex", ".bib", '' )
	else
		let l:fn = glob('*.bib')
	endif

	call Spit(1,a:dirchange,l:fn)
endfunction
com! -nargs=* -complete=file Vbib  call Vbib(0,<f-args>)
com! -nargs=* -complete=file Vbibl call Vbib(-1,<f-args>)
com! -nargs=* -complete=file Vbibr call Vbib(1,<f-args>)
cab vbib Vbib
cab vbibl Vbibl
cab vbibr Vbibr
