"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""  Plugin written by Noah Spurrier <noah@noah.org>
""    Thanks to Tom Purl for the original des3 tip.
""    maintained by XonqNopp
"" This is openssl plugin to ensure encryption with Vim
"" Last modified: Tue 30 Apr 2013 03:17:35 PM CEST
"" Version 3.4
""
"" To be always up-to-date:
"" GetLatestVimScripts: 2012 1 :AutoInstall: SpitVspit
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""

augroup openssl_encrypted
if exists("g:openssl_encrypted_loaded") && g:openssl_encrypted_loaded
    finish
endif
let g:openssl_encrypted_loaded = 1
let g:openssl_version = 3.4
"if exists("g:openssl_diff_pwd") == 0
	let g:openssl_diff_pwd = 0
"endif
if exists( "g:openssl_timeout" ) == 0
	let g:openssl_timeout = 60
endif
let g:openssl_timeout = g:openssl_timeout * 1000


autocmd!

function! s:OpenSSLReadPre()
    if has("filterpipe") != 1
        echo "Your systems sucks."
        exit 1
    endif
    set secure
    set cmdheight=3
    set viminfo=
    set clipboard=
    set noswapfile
    set noshelltemp
    set shell=/bin/sh
    set bin
	"" autocmd CurosrHold quit
	if g:openssl_timeout > 0
		autocmd BufReadPost,FileReadPost * execute "set updatetime=" . g:openssl_timeout
		autocmd CursorHold,CursorHoldI * qall!
	endif
endfunction

function! s:OpenSSLReadPost()
    " Most file extensions can be used as the cipher name, but
    " a few  need a little cosmetic cleanup.
    let l:cipher = expand("%:e")
    if l:cipher == "aes"
        let l:cipher = "aes-256-cbc -a"
    endif
    if l:cipher == "bfa"
        let l:cipher = "bf -a"
    endif
    let l:expr = "0,$!openssl " . l:cipher . " -d -salt -pass stdin -in " . expand("%")

    set undolevels=-1
    let l:a = inputsecret("  Enter password: ")
    " Replace encrypted text with the password to be used for decryption.
    execute "0,$d"
    execute "normal i". l:a
    " Replace the password with the decrypted file.
    silent! execute l:expr
    " Cleanup.
	if g:openssl_diff_pwd
		let g:old_pwd = l:a
	endif
    let l:a="Wake up, Neo"
    set undolevels&
    redraw!
    if v:shell_error
        silent! 0,$y
        silent! undo
        redraw!
        echoerr "ERROR -- COULD NOT DECRYPT"
		echohl Error
        echomsg "You may have entered the wrong password or"
        echomsg "your version of openssl may not have the given"
        echomsg "cipher engine built-in. This may be true even if"
        echomsg "the cipher is documented in the openssl man pages."
        echomsg "DECRYPT EXPRESSION: " . l:expr
		echohl None
        "echo "Press any key to continue..."
        "let char = getchar()
        return
    endif
    set nobin
    set cmdheight&
    set shell&
	if g:openssl_diff_pwd
		set modified
		set buftype=nowrite
		silent! !rm %
		redraw!
		set buftype=
	endif
    execute ":doautocmd BufReadPost ".expand("%:r")
    redraw!
endfunction

function! s:OpenSSLWritePre()
    set cmdheight=3
    set shell=/bin/sh
    set bin

    " Most file extensions can be used as the cipher name, but
    " a few  need a little cosmetic cleanup. AES could be any flavor,
    " but I assume aes-256-cbc format with base64 ASCII encoding.
    let l:cipher = expand("<afile>:e")
    if l:cipher == "aes"
        let l:cipher = "aes-256-cbc -a"
    endif
    if l:cipher == "bfa"
        let l:cipher = "bf -a"
    endif
    let l:expr = "0,$!openssl " . l:cipher . " -e -salt -pass stdin"

    let l:a  = inputsecret("    New password: ")
    let l:ac = inputsecret("  Confirm new password: ")
    if l:a != l:ac
        " This gives OpenSSLWritePost something to UNDO..
		silent! execute "0goto"
		silent! execute "normal iThis file has not been saved.\n"
        let l:a ="Wake up, Neo"
        let l:ac="Wake up, Neo"
        echoerr "ERROR -- COULD NOT ENCRYPT"
		echohl Error
        echomsg "The new password and the confirmation password did not match."
        echomsg "ERROR -- COULD NOT ENCRYPT"
		echohl None
        "echo "Press any key to continue..."
        redraw!
        "let char = getchar()
        return 1
    endif
	if g:openssl_diff_pwd
		if l:a == g:old_pwd
			" This gives OpenSSLWritePost something to UNDO..
			silent! execute "0goto"
			silent! execute "normal iThis file has not been saved.\n"
			let l:a ="Wake up, Neo"
			let l:ac="Wake up, Neo"
			let g:old_pwd = l:a
			echoerr "ERROR -- COULD NOT ENCRYPT"
			echohl Error
			echomsg "The new password MUST be different from the old one."
			echomsg "ERROR -- COULD NOT ENCRYPT"
			echohl None
			"echo "Press any key to continue..."
			redraw!
			"let char = getchar()
			return 1
		endif
		let g:old_pwd = "Wake up, Neo"
	endif
    silent! execute "0goto"
    silent! execute "normal i". l:a . "\n"
    silent! execute l:expr
    " Cleanup.
    let l:a ="Wake up, Neo"
    let l:ac="Wake up, Neo"
    redraw!
    if v:shell_error
        silent! 0,$y
        " Undo the encryption.
        silent! undo
        redraw!
        echoerr "ERROR -- COULD NOT ENCRYPT"
		echohl Error
        echomsg "Your version of openssl may not have the given"
        echomsg "cipher engine built-in. This may be true even if"
        echomsg "the cipher is documented in the openssl man pages."
        echomsg "ENCRYPT EXPRESSION: " . expr
        echomsg "ERROR FROM OPENSSL:"
        echomsg @"
        echomsg "ERROR -- COULD NOT ENCRYPT"
		echohl None
        "echo "Press any key to continue..."
        "let char = getchar()
        return 1
    endif
endfunction

function! s:OpenSSLWritePost()
    " Undo the encryption.
    silent! undo
    set nobin
    set shell&
    set cmdheight&
    redraw!
endfunction

autocmd BufReadPre,FileReadPre     *.des3,*.des,*.bf,*.bfa,*.aes,*.idea,*.cast,*.rc2,*.rc4,*.rc5,*.desx call s:OpenSSLReadPre()
autocmd BufReadPost,FileReadPost   *.des3,*.des,*.bf,*.bfa,*.aes,*.idea,*.cast,*.rc2,*.rc4,*.rc5,*.desx call s:OpenSSLReadPost()
autocmd BufWritePre,FileWritePre   *.des3,*.des,*.bf,*.bfa,*.aes,*.idea,*.cast,*.rc2,*.rc4,*.rc5,*.desx call s:OpenSSLWritePre()
autocmd BufWritePost,FileWritePost *.des3,*.des,*.bf,*.bfa,*.aes,*.idea,*.cast,*.rc2,*.rc4,*.rc5,*.desx call s:OpenSSLWritePost()

"
" The following implements a simple password safe for any file named
" '.auth.aes'. The file is encrypted with AES and base64 ASCII encoded.
" Folding is supported for == headlines == style lines.
"

function! HeadlineDelimiterExpression(lnum)
    if a:lnum == 1
        return ">1"
    endif
    return (getline(a:lnum)=~"^\\s*==.*==\\s*$") ? ">1" : "="
endfunction
"" autocmd .auth.aes
autocmd BufReadPost,FileReadPost   .auth.aes set foldexpr=HeadlineDelimiterExpression(v:lnum)
autocmd BufReadPost,FileReadPost   .auth.aes set foldlevel=0
autocmd BufReadPost,FileReadPost   .auth.aes set foldcolumn=0
autocmd BufReadPost,FileReadPost   .auth.aes set foldmethod=expr
autocmd BufReadPost,FileReadPost   .auth.aes set foldtext=getline(v:foldstart)
autocmd BufReadPost,FileReadPost   .auth.aes nnoremap <silent><space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<CR>
autocmd BufReadPost,FileReadPost   .auth.aes nnoremap <silent>q :q<CR>
autocmd BufReadPost,FileReadPost   .auth.aes highlight Folded ctermbg=red ctermfg=black
autocmd BufReadPost,FileReadPost   .auth.aes set updatetime=300000
autocmd CursorHold                 .auth.aes quit

" End of openssl_encrypted
augroup END

