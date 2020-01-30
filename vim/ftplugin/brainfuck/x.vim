"" chars are <>,.[]+-
"" Before reading...
"" Split on new char
"autocmd BufReadPost,BufWritePost *.b silent %s/<\([^<]\)/<\r\1/ge
"autocmd BufReadPost,BufWritePost *.b silent %s/>\([^>]\)/>\r\1/ge
"autocmd BufReadPost,BufWritePost *.b silent %s/,\([^,]\)/,\r\1/ge
"autocmd BufReadPost,BufWritePost *.b silent %s/\.\([^.]\)/.\r\1/ge
"autocmd BufReadPost,BufWritePost *.b silent %s/\[\([^\[]\)/[\r\1/ge
"autocmd BufReadPost,BufWritePost *.b silent %s/\]\([^\]]\)/]\r\1/ge
"autocmd BufReadPost,BufWritePost *.b silent %s/+\([^+]\)/+\r\1/ge
"autocmd BufReadPost,BufWritePost *.b silent %s/-\([^-]\)/-\r\1/ge
"" Split long chars in 5
"autocmd BufReadPost,BufWritePost *.b silent %s/\(.\)\1\1\1\1\1/\1\1\1\1\1\r\1/ge
"""
"" Before writing...
"" Remove comments
"autocmd BufWritePre *.b silent %s/[^.,\[\]<>+-]//ge
"" Remove newlines and spaces
"autocmd BufWritePre *.b silent %s/[\r\n\t ]//ge
