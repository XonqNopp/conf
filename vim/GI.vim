:set spelllang=en,fr
<c-a>     " increment number under cursor
<c-x>     " decrement number under cursor
:TOhtml  svn

" Edit binary file
vim -b file.bin
set display=uhex
:%!xxd
:%!xxd -r

"" Converts lines with rot13:
:20,30!rot13
"" Replace current line with shell date output:
!!date

"" character code:
character code: ga - search/sub: \%dXXX \%xXX/\%uXXXX/\%UXXXXXXXX

"" sub replace
s/[0-9]\+/\=submatch(0)+1/
s/^/\=line(".")/
s@[0-9]\+@\=submatch(0)/2@

"" Estear Eggs
:help!
:help 42
:help holy-grail
:help |
:Ni!
autocmd UserGettingBored * echo "Hello"
help UserGettingBored
