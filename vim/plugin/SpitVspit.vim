" This is SpitVspit plugin to split among many files,
"  even :sp *.cpp<cr> works!!

" Inspired from http://vim.wikia.com/wiki/Opening_multiple_files_from_a_single_command-line
"  By salmanhalim

" TODO:
" also tabs
" Problem with spaces in filename

if exists("g:loaded_SpitVspit") && g:loaded_SpitVspit
	finish
endif
let g:loaded_SpitVspit = 1
let g:SpitVspit_version = 2.2

function Spit(choice, direction, my_count, ...)
	""
	"" choice: 0 for split (default), +1 for vsplit, -1 for wspit, 2 for edit, 3 for tabedit
	""
	let l:sp = ""
	if a:my_count > 0
		let l:sp = a:my_count
	endif
	let l:sp .= "split"
	let l:isbelow = &splitbelow
	let l:isright = &splitright
	let l:dirchange = ""
	let l:w = 0
	let l:memory = 0
	let l:old_ok = 0
	let l:keep_first = ""
	let l:stop_cond = 1
	let l:old_file = @%
	let i = a:0
	if a:choice == 0 && ((a:direction > 0 && l:isbelow) || (a:direction < 0 && !l:isbelow))
		let l:dirchange = "set invsplitbelow"
	elseif a:choice == 1
		let l:sp = "vsplit"
		if (a:direction > 0 && !l:isright) || (a:direction < 0 && l:isright)
			let l:dirchange = "set invsplitright"
		endif
	elseif a:choice == -1
		let l:w = 1
		let l:sp = "vsplit"
		if (a:direction > 0 && !l:isright) || (a:direction < 0 && l:isright)
			let l:dirchange = "set invsplitright"
		endif
	elseif a:choice == 2
		if l:old_file != ""
			"let l:sp = l:sp . " " . l:old_file
			let l:old_ok = 1
			let l:sp = "99argadd"
		else
			let l:sp = "args"
		endif
		let i = 1
	elseif a:choice == 3
	endif
	execute l:dirchange
	if a:0 == 0 || empty(a:1)
		if a:choice < 2
			execute l:sp
		endif
	else
		while l:stop_cond
			execute "let file = expand(a:" . i .")"
			if match(file, '*') > -1 || match(file, '\n') > -1
				let l:files = expand(file)
				if match(l:files, '*') != -1
					echoerr "Sorry, files " . l:files . " not found..."
					break
				endif
				while l:files != ""
					let l:thisfile = substitute(l:files, "\n.*$", "", "")
					let l:files = substitute(l:files, l:thisfile, "", "")
					let l:files = substitute(l:files, "^\n", "", "")
					if l:keep_first == ""
						let l:keep_first = l:thisfile
					endif
					if a:choice < 2 && l:thisfile != l:old_file
						"" Don't split *.* if current file
						execute l:sp . " " . l:thisfile
						if a:choice == -1 && l:w == 1
							let l:w = 0
							let l:sp = "split"
						endif
					elseif a:choice == 2
						let l:sp = l:sp . " " . l:thisfile
					endif
				endwhile
			else
				if l:keep_first == ""
					let l:keep_first = file
				endif
				if a:choice < 2
					execute l:sp . " " . file
					if a:choice == -1 && l:w == 1
						let l:w = 0
						let l:sp = "split"
					endif
				else
					let l:sp .= " " . file
				endif
			endif
			if a:choice < 2
				let i = i - 1
				let l:stop_cond = i > 0
			else
				let i = i + 1
				let l:stop_cond = i <= a:0
			endif
		endwhile
		if a:choice == 2
			execute l:sp
			if l:old_ok
				while @% != l:keep_first
					execute "next"
				endwhile
			endif
		endif
	endif
	execute l:dirchange
endfunction

"" Creating new command names
com! -nargs=* -complete=file -range=0 Spit       call Spit( 0, 0, <count>, <f-args>)
com! -nargs=* -complete=file -range=0 SpitUp     call Spit( 0, 1, <count>, <f-args>)
com! -nargs=* -complete=file -range=0 SpitDown   call Spit( 0,-1, <count>, <f-args>)
com! -nargs=* -complete=file -range=0 Vspit      call Spit( 1, 0, <count>, <f-args>)
com! -nargs=* -complete=file -range=0 VspitRight call Spit( 1, 1, <count>, <f-args>)
com! -nargs=* -complete=file -range=0 VspitLeft  call Spit( 1,-1, <count>, <f-args>)
com! -nargs=* -complete=file -range=0 Wspit      call Spit(-1, 0, <count>, <f-args>)
com! -nargs=* -complete=file -range=0 WspitRight call Spit(-1, 1, <count>, <f-args>)
com! -nargs=* -complete=file -range=0 WspitLeft  call Spit(-1,-1, <count>, <f-args>)
com! -nargs=* -complete=file          E          call Spit( 2, 0, 0,       <f-args>)
"" Redo command mapping
"" Problem with the built-in commands (v)sp when giving a count, but I assume
""   a count is given only for case where the built-in commands are well working.
cabbrev Sp   Spit
cabbrev sp   Spit
cabbrev Spu  SpitUp
cabbrev spu  SpitUp
cabbrev Spd  SpitDown
cabbrev spd  SpitDown
cabbrev Vsp  Vspit
cabbrev vsp  Vspit
cabbrev Vspr VspitRight
cabbrev vspr VspitRight
cabbrev Vspl VspitLeft
cabbrev vspl VspitLeft
cabbrev Wsp  Wspit
cabbrev wsp  Wspit
cabbrev Wspr WspitRight
cabbrev wspr WspitRight
cabbrev Wspl WspitLeft
cabbrev wspl WspitLeft
"cabbrev e    E
"" Is the last one a good idea???
