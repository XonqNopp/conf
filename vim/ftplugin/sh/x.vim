setlocal cindent
setlocal foldmethod=marker
setlocal foldcolumn=2

autocmd BufWritePost * ShellCheck! -x

