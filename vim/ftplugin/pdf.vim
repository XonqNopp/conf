"" To be readable as a text file
setlocal display=uhex
%!xxd
"" To get back to pdf format: (check vimrc bin autocmd)
map <silent> <buffer> <F2> :%!xxd -r
