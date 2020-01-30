" environment
" array (equ)
iabbrev <buffer> bea <esc>:setlocal nocindent<cr>A\begin{align}XXXXX<cr>\end{align}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
iabbrev <buffer> beano <esc>:setlocal nocindent<cr>A\begin{align*}XXXXX<cr>\end{align*}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" cases (math)
iabbrev <buffer> bec <esc>:setlocal nocindent<cr>A\begin{cases}XXXXX<cr>\end{cases}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" pmatrix (matrix with parantheses)
iabbrev <buffer> bep <esc>:setlocal nocindent<cr>A\begin{pmatrix}XXXXX<cr>\end{pmatrix}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" beamer frame
iabbrev <buffer> bef <esc>:setlocal nocindent<cr>A\begin{frame}%{#&%}%%{{{<cr>%\begin{center}XXXXX<cr>%\end{center}<cr>\end{frame}<cr>\note{%<cr>#&%<cr>}<cr>%% }}}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" longtable
iabbrev <buffer> belgt <esc>:setlocal nocindent<cr>A\begin{longtable}XXXXX}\hline<cr>\end{longtable}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" spreadtab
iabbrev <buffer> bespt <esc>:setlocal nocindent<cr>A\nprounddigits{2}<cr>\begin{spreadtab}XXXXX}\hline<cr>\end{spreadtab}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" itemize
iabbrev <buffer> bei <esc>:setlocal nocindent<cr>A\begin{itemize}<cr>\itemXXXXX<cr>\end{itemize}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" enumerate
iabbrev <buffer> bee <esc>:setlocal nocindent<cr>A\begin{enumerate}<cr>\itemXXXXX<cr>\end{enumerate}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" description
iabbrev <buffer> bed <esc>:setlocal nocindent<cr>A\begin{description}<cr>\itemXXXXX] #&%<cr>\end{description}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" beamer itemize with alert on new
iabbrev <buffer> beia <esc>:setlocal nocindent<cr>A\begin{itemize}[<+-\| alert@+>]<cr>\itemXXXXX<cr>\end{itemize}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" beamer enumerate with alert on new
iabbrev <buffer> beea <esc>:setlocal nocindent<cr>A\begin{enumerate}[<+-\| alert@+>]<cr>\itemXXXXX<cr>\end{enumerate}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" beamer itemize
iabbrev <buffer> beinoa <esc>:setlocal nocindent<cr>A\begin{itemize}[<+->]<cr>\itemXXXXX<cr>\end{itemize}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" beamer enumerate
iabbrev <buffer> beenoa <esc>:setlocal nocindent<cr>A\begin{enumerate}[<+->]<cr>\itemXXXXX<cr>\end{enumerate}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" listing
iabbrev <buffer> belst <esc>:setlocal nocindent<cr>A\begin{lstlisting}[styleXXXXX, caption={#&%}, label=lst:#&%]<cr><cr>\end{lstlisting}<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" inline listing
iabbrev <buffer> lstinst \lstinputlisting[styleXXXXX, caption={#&%}, linerange={#&%-#&%}]{#&%}<esc>?XXXXX<cr>cw
" inline listing without style
iabbrev <buffer> lstinnost \lstinputlisting[caption=XXXXX}, linerange={#&%-#&%}]{#&%}<esc>?XXXXX<cr>cw
" inline listing without style nor caption
iabbrev <buffer> lstinnono \lstinputlisting[linerangeXXXXX-#&%}]{#&%}<esc>?XXXXX<cr>cw

" Sections
" chapter (no fold marker because of include)
iabbrev <buffer> ccc <esc>:setlocal nocindent<cr>A\chapterXXXXX}<cr>%\label{sec:#&%}<cr>%%<esc>?XXXXX<cr>:setlocal cindent<cr>cw
" section
iabbrev <buffer> sss <esc>:setlocal nocindent<cr>A\sectionXXXXX}%%{{<cr>%\label{sec:#&%}<cr>%%<cr><cr>%% }}}<esc>?XXXXX<cr>A{<esc>N:setlocal cindent<cr>cw
" sub
iabbrev <buffer> ssss <esc>:setlocal nocindent<cr>A\subsectionXXXXX}%%{{<cr>%\label{sec:#&%}<cr>%%<cr><cr>%% }}}<esc>?XXXXX<cr>A{<esc>N:setlocal cindent<cr>cw
" subsub
iabbrev <buffer> sssss <esc>:setlocal nocindent<cr>A\subsubsectionXXXXX}%%{{<cr>%\label{sec:#&%}<cr>%%<cr><cr>%% }}}<esc>?XXXXX<cr>A{<esc>N:setlocal cindent<cr>cw
" para
iabbrev <buffer> pppppp <esc>:setlocal nocindent<cr>A\paragraphXXXXX}\mbox{}\\%%{{<cr>%\label{sec:#&%}<cr>%%<cr><cr>%% }}}<esc>?XXXXX<cr>A{<esc>N:setlocal cindent<cr>cw
" subpara
iabbrev <buffer> ppppppp <esc>:setlocal nocindent<cr>A\subparagraphXXXXX}\mbox{}\\%%{{<cr>%\label{sec:#&%}<cr>%%<cr><cr>%% }}}<esc>?XXXXX<cr>A{<esc>N:setlocal cindent<cr>cw

" Figure
iabbrev <buffer> fiG <esc>:setlocal nocindent textwidth=0 colorcolumn=1<cr>A\begin{figure}[H]%% #&% {{{<cr>\begin{center}<cr>\includegraphics[width=110mm]XXXXX.eps}<cr>\vspace{-5mm}<cr>\end{center}<cr>\caption{\footnotesize #&%\label{fig:#&%}}<cr>\vspace{-5mm}<cr>\end{figure}%%}}}<cr>%%<esc>?XXXXX<cr>:setlocal cindent textwidth=80 colorcolumn=81<cr>cw

" Double figure
iabbrev <buffer> fiG2 <esc>:setlocal nocindent textwidth=0 colorcolumn=1<cr>A\begin{figure}[H]%% #&% {{{<cr>\begin{center}<cr>\includegraphics[width=110mm]XXXXX.eps}<cr>\vspace{-5mm}<cr>\end{center}<cr>\caption{\footnotesize #&%\label{fig:#&%}}<cr>\vspace{-5mm}<cr>\end{figure}<cr>%%<cr>\begin{figure}[H]<cr>\begin{center}<cr>\includegraphics[width=110mm]{#&%.eps}<cr>\vspace{-5mm}<cr>\end{center}<cr>\caption{\footnotesize #&%\label{fig:#&%}}<cr>\vspace{-5mm}<cr>\end{figure}%% }}}<cr>%%<esc>?XXXXX<cr>:setlocal cindent textwidth=80 colorcolumn=81<cr>cw

" Double subfigure aside
iabbrev <buffer> sufiG <esc>:setlocal nocindent textwidth=0 colorcolumn=1<cr>A\beginXXXXXfigure}[H]%% #&% {{{<cr>\begin{center}<cr>\subfloat[\footnotesize #&%]{%<cr><tab>\includegraphics[width=70mm]{#&%.eps}%<cr>\label{fig:#&%}%<cr>}<cr>\hspace{3mm}<cr>\subfloat[\footnotesize #&%]{%<cr><tab>\includegraphics[width=70mm]{#&%.eps}%<cr>\label{fig:#&%}%<cr>}<cr>\vspace{-5mm}<cr>\end{center}<cr>\caption{\footnotesize #&%\label{fig:#&%}}<cr>\vspace{-5mm}<cr>\end{figure}%%}}}<cr>%%<esc>?XXXXX<cr>:setlocal cindent textwidth=80 colorcolumn=81<cr>c5l

" Triple figure aside
iabbrev <buffer> sufiG3 <esc>:setlocal nocindent textwidth=0 colorcolumn=1<cr>A\beginXXXXXfigure}[H]%% #&% {{{<cr>\begin{center}<cr>\subfloat[\footnotesize #&%]{%<cr><tab>\includegraphics[width=53mm]{#&%.eps}%<cr>\label{fig:#&%}%<cr>}<cr>\hspace{3mm}<cr>\subfloat[\footnotesize #&%]{%<cr><tab>\includegraphics[width=53mm]{#&%.eps}%<cr>\label{fig:#&%}%<cr>}<cr>\hspace{3mm}<cr>\subfloat[\footnotesize #&%]{%<cr><tab>\includegraphics[width=53mm]{#&%.eps}%<cr>\label{fig:#&%}%<cr>}<cr>\vspace{-5mm}<cr>\end{center}<cr>\caption{\footnotesize #&%\label{fig:#&%}}<cr>\vspace{-5mm}<cr>\end{figure}%%}}}<cr>%%<esc>?XXXXX<cr>:setlocal cindent textwidth=80 colorcolumn=81<cr>c5l

" Double subfigure one over the other
iabbrev <buffer> sufiG2 <esc>:setlocal nocindent textwidth=0 colorcolumn=1<cr>A\beginXXXXXfigure}[H]%% #&% {{{<cr>\begin{center}<cr>\subfloat[\footnotesize #&%]{%<cr><tab>\includegraphics[width=110mm]{#&%.eps}%<cr>\label{fig:#&%}%<cr>}\\<cr>\subfloat[\footnotesize #&%]{%<cr><tab>\includegraphics[width=110mm]{#&%.eps}%<cr>\label{fig:#&%}%<cr>}<cr>\vspace{-5mm}<cr>\end{center}<cr>\caption{\footnotesize #&%\label{fig:#&%}}<cr>\vspace{-5mm}<cr>\end{figure}%%}}}<cr>%%<esc>?XXXXX<cr>:setlocal cindent textwidth=80 colorcolumn=81<cr>c5l

" Wrapfigure
iabbrev <buffer> wfiG <esc>:setlocal nocindent textwidth=0 colorcolumn=1<cr>A\begin{wrapfigure}XXXXX}{75mm}%% #&% {{{<cr>\vspace{-5mm}<cr>\includegraphics[width=75mm]{#&%.eps}<cr>\vspace{-5mm}<cr>\caption{\footnotesize #&%}<cr>\vspace{-5mm}<cr>\end{wrapfigure}%%}}}<cr>%%<esc>?XXXXX<cr>:setlocal cindent textwidth=80 colorcolumn=81<cr>cw

" a0poster
iabbrev <buffer> ppool %% PAUL %%%%% {{{<cr>\paulXXXXX}{#&%}{#&%}{#&%}{#&%}{<cr>%%<cr>#&%<cr>%%<cr>}<cr>%%<cr>%% }}}<cr>%%<cr><esc>?XXXXX<cr>cw

setlocal cindent
setlocal foldmethod=marker	" To have section folded
"" Comments
let b:ComChar = "%"

" Put section title in fold header (to be deprecated)
"map <buffer> <F4> 0f{lvh%hyk$pjjj0
" Trying another way?
"map <buffer> <F4> y%k$pF{x


" For the lazy people who type accented letters
inoremap <buffer> é \'e
inoremap <buffer> è \`e
inoremap <buffer> ê \^e
inoremap <buffer> ë \"e
inoremap <buffer> á \'a
inoremap <buffer> à \`a
inoremap <buffer> â \^a
inoremap <buffer> ä \"a
inoremap <buffer> í \'i
inoremap <buffer> ì \`i
inoremap <buffer> î \^i
inoremap <buffer> ï \"i
inoremap <buffer> ó \'o
inoremap <buffer> ò \`o
inoremap <buffer> ô \^o
inoremap <buffer> ö \"o
inoremap <buffer> ú \'u
inoremap <buffer> ù \`u
inoremap <buffer> û \^u
inoremap <buffer> ü \"u
inoremap <buffer> ç \c{c}
inoremap <buffer> œ \oe 
inoremap <buffer> Œ \OE 
inoremap <buffer> æ  \ae 
inoremap <buffer> Æ \AE 
inoremap <buffer> oeil \oe il
inoremap <buffer> Oeil \OE il
inoremap <buffer> oeuf \oe uf
inoremap <buffer> Oeuf \OE uf
inoremap <buffer> oeuvre \oe uvre
inoremap <buffer> Oeuvre \OE uvre
inoremap <buffer> choeur ch\oe ur
inoremap <buffer> Choeur Ch\oe ur

"syntax match texComment "%.*" contains=@NoSpell
autocmd BufReadPost * syntax match texComment "%.*" contains=@NoSpell
autocmd Syntax * syntax match texComment "%.*" contains=@NoSpell

if has("spell")
	"map <buffer> ;s viW"sy:spellgood getreg('s')<cr>
	" Marche pas :-(
	map <buffer> _w viW
	setlocal spell			" To check the spell
	" How to choose the language?
	setlocal spelllang=en
	"setlocal spelllang=fr
	"setlocal spelllang=en,fr
	if match(&spelllang,",") > -1
		execute "setlocal spellfile=$vash/vim/spell/en.utf-8.add"
	else
		execute "setlocal spellfile=$vash/vim/spell/" . &spelllang . ".utf-8.add"
	endif
	"autocmd BufReadPost * execute "setlocal spellfile=$vash/vim/spell/" . &spelllang . ".utf-8.add"
endif
autocmd BufReadPost *.log,*.sty,*.aux,*.toc setlocal nospell

