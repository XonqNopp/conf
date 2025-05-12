" This is FoldImproved plugin to have a nice fold text
" (especially removing my LaTeX headers)

" When working, upload to vim.org with MapComments (change keys to be variables to enable other to change them)

if exists('g:loaded_FIm') && g:loaded_FIm
    finish
endif
let g:loaded_FIm = 1
let g:FIm_version = 0.1


let s:FoldImprovedEnable = 1
if (exists('g:FoldImprovedEnable') && !g:FoldImprovedEnable) || (exists('b:FoldImprovedEnable') && !b:FoldImprovedEnable)
    let s:FoldImprovedEnable = 0
endif

function FoldImproved()
    "" set variables
    let l:leftstr   = ''
    let l:rightstr  = ''
    let l:minlen    = 2
    let l:padchar   = '-'
    "" Getting info
    let l:foldedlines   = v:foldend - v:foldstart + 1
    let l:textwidth     = winwidth(0) - &foldcolumn - (&number ? &numberwidth : 0)
    let l:halfwidth     = ceil(l:textwidth/2.0)
    let l:totallines    = line('$')
    let l:foldedpercent = printf('%.0f', 100.0 * l:foldedlines / l:totallines) . '%'

        "" Get name
        let l:name = getline(v:foldstart)
        "" C++/PHP check
        if match(l:name, '^\s*\/\*\+$') > -1
            let l:name = getline(v:foldstart+1)
        endif
        "" Python check
        if match(l:name, '^ *"""$') > -1
            let l:name = getline(v:foldstart+1)
        endif
        "" Erase the fold marks
        let l:name = substitute(l:name, '\( \|\t\)*{{{[0-9]*\( \|\t\)*', '', '')
        let l:originalname = l:name
        "" Closing not necessary because not on the same line

        "" Erase the latex position comments
        let l:name = substitute(l:name, '%\+ \+\(chapter\|section\|sub\(-sub\)\?\|\(sub-\)*paragraph\) \+%\+ *', '', 'i')
        let l:name = substitute(l:name, '^%\?\s*\\begin{[^}]\+}%%\(.*\)$', '\1', 'i')
        let l:name = substitute(l:name, '^%\?\s*\\begin{[^}]\+}{\([^}]\+\)}.*$', '\1', 'i')
        let l:name = substitute(l:name, '^%\?\s*\\begin{frame}%\?{\?\(#&%}\)\?', '', 'i')
        let l:name = substitute(l:name, '^%\?\s*\\[A-Za-z]\+\*\?\(\[[^\]]\+\]\)\?{', '', 'i')
        let l:name = substitute(l:name, '\\label{[^}]*}\s*', '', 'i')
        let l:name = substitute(l:name, '\\item\(\[[^\]]*\]\)\? *', '', '')
        let l:name = substitute(l:name, '}.*%', '', '')
        "" Erase comment chars (using b: vars)
            "" Prepare comment chars to be escaped
            "" Characters to escape: / * "
                "" ComChar
                if exists('b:ComChar')
                    let l:ComCharEscaped = EscapeBchars(b:ComChar)
                    let l:ComCharEscaped = "^\\s*" . l:ComCharEscaped . "\\+\\s*"
                endif
            ""
                "" ComCharStartPat
                if exists('b:ComCharStart')
                    if exists('b:ComCharStartMore')
                        let l:ComCharStartPat = EscapeBchars(b:ComCharStart, b:ComCharStartMore, 1)
                        let l:ComCharStartMorePat = "\\s*" . EscapeBchars(b:ComCharStartMore) . "\\+\\s*"
                    else
                        let l:ComCharStartPat = EscapeBchars(b:ComCharStart)
                    endif
                    let l:ComCharStartPat = "\\s*" . l:ComCharStartPat . "\\+\\s*"
                endif
            ""
                "" ComCharStopPat
                if exists('b:ComCharStop')
                    if exists('b:ComCharStopMore')
                        let l:ComCharStopPat = EscapeBchars(b:ComCharStop, b:ComCharStopMore, -1)
                    else
                        let l:ComCharStopPat = EscapeBchars(b:ComCharStop)
                    endif
                    let l:ComCharStopPat = "\\s*" . l:ComCharStopPat . "\\+\\s*"
                endif
            ""
                "" Remove them from the string
                if exists('l:ComCharEscaped')
                    let l:name = substitute(l:name, l:ComCharEscaped, '', 'g')
                endif
                if exists('l:ComCharStartPat')
                    let l:name = substitute(l:name, l:ComCharStartPat, '', 'g')
                endif
                if exists('l:ComCharStartMorePat')
                    let l:name = substitute(l:name, l:ComCharStartMorePat, '', 'g')
                endif
                if exists('l:ComCharStopPat')
                    let l:name = substitute(l:name, l:ComCharStopPat, '', 'g')
                endif

        "" Remove python docstring char
        let l:name = substitute(l:name, ' *""" *', '', 'g')
        "" Change tabs to space to remove superflu
        let l:name = substitute(l:name, '\t\+', '    ', '')
        "" Erase spaces at beginning and end of line
        let l:name = substitute(l:name, ' \+$', '', '')
        let l:name = substitute(l:name, '^ \+', '', '')

        "" check if comment says disabled
        if matchstr(l:name, '(DISABLED)') !=? ''
            "echomsg l:name
            let l:name = substitute(l:name, ' *(DISABLED)', '', '')
            let l:name = '  [---' . l:name . '---]  '
            let l:padchar = '|'
        endif

        if l:name ==? ''
            if l:originalname ==? ''
                let l:name = '## no title for this fold ##'
            else
                let l:name = l:originalname
            endif
        endif

    " set text
    let l:rightmargin = '  '  " because other plugins will shift display to right and we won't know here
    let l:rightpadding = ''
    if strwidth(v:foldlevel) == 1
        let l:rightpadding = '0'
    endif
    let l:rightstr = v:folddashes . 'FL' . l:rightpadding . v:foldlevel . l:rightmargin

    let l:leftstr = v:foldend . ': ' . l:foldedlines . 'l (' . l:foldedpercent . ')   ' . l:name

    if strwidth(l:leftstr) >= l:textwidth
        let newwidth = l:textwidth - 2
        let newwidth -= 3  " ellipsis
        let newwidth -= 4  " rightstr with enough fold dash
        let l:leftstr = l:leftstr[:newwidth] . '...'
    endif

    let l:leftstr .= ' '

    let l:explen = l:textwidth - strwidth(l:leftstr . l:rightstr)

    return l:leftstr . repeat(l:padchar, l:explen) . l:rightstr
endfunction


if s:FoldImprovedEnable
    if (exists('g:FoldImprovedLocal') && g:FoldImprovedLocal) || (exists('b:FoldImprovedLocal') && b:FoldImprovedLocal)
        setlocal foldtext=FoldImproved()
    else
        set foldtext=FoldImproved()
    endif
endif


"" vim: foldmethod=indent:
