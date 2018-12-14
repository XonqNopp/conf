" Matching groups
syntax match GitStar '^[*\\|/ _.-]*[*/|\\_.-]'
syntax match GitTag '(tag: [^,)]*)'
syntax match GitTag 'tag: [^,)]*'
syntax match GitHash '[0-9a-f]\{7,8\}'
syntax match GitBra "'\?\(HEAD\|master\|development\|\(\(hot\)\?fix\|feat\(ure\)\?\)_[^,) ]*\|\(upstream\|origin\)/[^,) ]*\|\([Mm]erge branch\|into\) '[^']*'\)'\?"
syntax match GitWho ' [^}]* %'hs=s+1,he=e-2
syntax match GitTime '{[0-9]\{4\}\(-[0-9]\{2\}\)\{2\} [0-9]\{2\}\(:[0-9]\{2\}\)\{2\} [-+ ][0-9]\{4\}}'
syntax keyword GitSpecial NOT
syntax match GitHEAD '[^/]HEAD'hs=s+1

" Highlighting groups
highlight def link GitStar DiffAdd
highlight def link GitHash PreProc
highlight def link GitBra Constant
highlight def link GitTag Special
highlight def link GitTime Comment
highlight def link GitWho Statement
highlight def link GitSpecial ErrorMsg
highlight def link GitHEAD TabLineSel

set nolinebreak

" Go to HEAD
call cursor(1,1)
call searchpos("[^/]HEAD", "c")
execute "normal 0zz"

