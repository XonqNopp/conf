setlocal cinwords=if,else,elseif,while,do,for,function,switch
setlocal cindent
setlocal foldmethod=indent
setlocal textwidth=120
if &ft == "php"
	let b:ComChar = "//"
	let b:ComCharStart = "/*"
	let b:ComCharStop = "*/"
endif

inoremap <buffer> é &eacute;
inoremap <buffer> è &egrave;
inoremap <buffer> ê &ecirc;
inoremap <buffer> ë &euml;
inoremap <buffer> á &aacute;
inoremap <buffer> à &agrave;
inoremap <buffer> â &acirc;
inoremap <buffer> ä &auml;
inoremap <buffer> í &iacute;
inoremap <buffer> ì &igrave;
inoremap <buffer> î &icirc;
inoremap <buffer> ï &iuml;
inoremap <buffer> ó &oacute;
inoremap <buffer> ò &ograve;
inoremap <buffer> ô &ocirc;
inoremap <buffer> ö &ouml;
inoremap <buffer> ú &uacute;
inoremap <buffer> ù &ugrave;
inoremap <buffer> û &ucirc;
inoremap <buffer> ü &uuml;
inoremap <buffer> ç &ccedil;
inoremap <buffer> ñ &ntilde;
inoremap <buffer> Ñ &Ntilde;
"inoremap <buffer> œ \oe 
"inoremap <buffer> Œ \OE 
"inoremap <buffer> æ  \ae 
"inoremap <buffer> Æ \AE 

