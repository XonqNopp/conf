"" For dumping external svn dirs
"autocmd BufEnter */hooks/pre-revprop-change.tmpl execute "normal G$r0"
"autocmd BufEnter */hooks/pre-revprop-change.tmpl execute "saveas " . expand("%:h") . "/pre-revprop-change"
"autocmd BufEnter */hooks/pre-revprop-change.tmpl quit
"" Disabled since replaced by short inline perl commands (see svn_ext_dump file)
"autocmd BufEnter */hooks/pre-revprop-change.tmpl echoerr "Woot"
"echoerr "Noob..."
