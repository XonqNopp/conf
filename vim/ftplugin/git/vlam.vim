setlocal scrollbind cursorbind nonumber nolinebreak nowrap
"" Matching groups
syntax match GitWho '[^0-9]*'
syntax match GitHash '^\^\?[0-9a-f]\{7,8\}'
syntax match GitUncommited '^Not Committed Yet'
syntax match GitTime '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\} [+ -][0-9]\{2\}'
syntax match GitLine '[0-9]\+)'
""
"" Highlighting groups
highlight def link GitHash PreProc
highlight def link GitUncommited Special
highlight def link GitTime Comment
"" Still available: DiffAdd Constant Statement
"highlight def link GitStar DiffAdd
"highlight def link GitLine Constant
highlight def link GitWho Statement
""
"" Also need to set some stuff in main file
wincmd l
setlocal scrollbind cursorbind nolinebreak nowrap foldlevel=99
