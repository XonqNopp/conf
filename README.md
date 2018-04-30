# Vim, Bash, et. al.

This repository contains my personal configuration files.
And some stuff too.


# Programming tricks

## Vim

### General tips

* C-a C-x: When the cursor is on a number in normal mode, you can increment or decrement it by executing respectively

  ```vimscript
  CTRL-a
  CTRL-x
  ```

* xxd: You can read (and maybe edit?) binary files by using the shell's command `xxd` in a file by doing so:

  ```vimscript
  :%!xxd
  ```

  See also `:help xxd`

* character code and search/replace: Vim can display the code of the character under the cursor in normal mode.
  The command is `ga`.
  You can use the code then to search or replace some characters.
  Decimal code can be matched with `\\%d...`,
  hexadecimal with `\\%x...` and so on.
  All are listed in `:help \\%d`

* replace computed submatch: If you want to replace all the numbers on the line with half the value, you can run:

  ```vimscript
  :s;[0-9]\+;\=submatch(0)/2;g
  ```

* insert line number: To insert the line number at the beginning of the line:

  ```vimscript
  :s/^/\=line(\".\")/
  ```



### Easter eggs

```vimscript
:help!
:help 42
:help holy-grail
:help |
:Ni!
:autocmd UserGettingBored * echo "Hello"
:help UserGettingBored
:set rightleft
:set revins
```


## Shell, bash and SSH

* Variable operations:

  ```bash
  var="salut ca va bien"
  $var             = salut ca va bien
  ${var#*a}        = lut ca va bien
  ${var##*a}       =  bien
  ${var%a*}        = salut ca v
  ${var%%a*}       = s
  ${var/va/va pas} = salut ca va pas bien
  ${var/a/y}       = sylut ca va bien
  ${var//a/y}      = sylut cy vy bien
  ```

* Check if sudo:

  ```bash
  if (( $UID == 0 )); then
  ```

* Remove temporary sudo rights (if any):

  ```bash
  sudo -k
  ```

* redirect IO
  * Redirect STDOUT to file:

    ```bash
    echo "hello world" > file.txt
    ```

  * Redirect STDERR to file:

    ```bash
    echo "hello world" 2> file.txt
    ```

  * Redirect STDOUT and STDERR to file:

    ```bash
    echo "hello world" >& file.txt
    ```

  * Redirect STDOUT to STDERR:

    ```bash
    echo "hello world" 1>&2
    ```

  * Redirect STDERR to STDOUT:

    ```bash
    echo "hello world" 2>&1
    ```
* Numeric for loop (bash):
  ```bash
  for i in {1..10}; do
  ```

* Make special behaviour on exit (trap exit):
  ```bash
  function your_function_name() {
	  ...
  }
  trap your_function_name EXIT
  ```

* command completion: Make a command suggests input (for instance .tex files):
  ```bash
  complete -f -X '!*.tex' your_command_name
  ```


## Python

* `assert` calls can be disabled by calling `python -O` or `python -OO` (optimize flag)
* If you want to implement something which requires to be very performant, you can write it in fortran and use `f2py` to compile it into a python module.


## LaTeX

A very good and complete reference is https://en.wikibooks.org/wiki/LaTeX

### Installation

* texlive official source is recommended.  Available sources in standard PPA are not recent enough...
* to update an official texlive installation, use the texlive manager (tlmgr): `tlmgr update --self --all`

### Packages

Here are packages of interest.
To get more information about a given package, use `texdoc package_name` or look at http://ctan.org


* lmodern and fontenc: these are required to make the text copiable from the PDF:

  ```LaTeX
  \usepackage{lmodern}
  \usepackage[T1]{fontenc}
  ```

* babel: To have your text displayed according to the standards of the language you are writing in, you need:

  ```LaTeX
  \usepackage[english]{babel}
  ```

* hyperref: this package allows you to make links inside and outside the document.
  * setup: once loaded you can set it up:

    ```LaTeX
	\hypersetup{
	  colorlinks        = true,
	  bookmarks         = true,
	  bookmarksnumbered = false,
	  linkcolor         = black,
	  urlcolor          = blue,
	  citecolor         = blue,
	  filecolor         = blue,
	  hyperfigures      = true,
	  breaklinks        = false,
	  ps2pdf,\n";
	  pdftitle          = {\ThisTitle},
	  pdfsubject        = {\ThisTitle},
	  pdfauthor         = {\ThisAuthors}
	}
    ```

  * commands: you can also use the following commands:

	```LaTeX
	\url{website link}
	\href{website link}{text to display}
	\href[reference in document]{text to display}
	\href{mailto:me@mail.com}{email me}
	```

  * There also is a `Form` environment so users can fill in the PDF directly:

	```LaTeX
	\TextField
	\ChoiceMenu
	```

* enumitem: if you want to get rid of the extra space in lists:

  ```LaTeX
  \usepackage{enumitem}
  \setlist{noitemsep}
  ```

* tocbibind: To get the bibliography and the index numbered and in the TOC:

  ```LaTeX
  \usepackage[section,numbib,nottoc,numindex]{tocbibind}
  ```

* fancyhdr: To set headers and footers, use the `fancyhdr` package.
  Using `\fancypagestyle{plain}` can help having the same page design everywhere (otherwise first page of chapters can be different).

* others useful packages:
  * listings: nice formatted code snippets
  * tikz: impressive schematics
  * draftwatermark: watermark background
  * ifthen: conditional behaviour
  * multicol: multicolumn in tables
  * lastpage: places a reference on last page
  * spreadtab: spreadsheet tables
  * colortbl: colored tables

### document design

* frenchspacing: To remove the extra space after each sentence, use `\frenchspacing`
* margins: LaTeX default margins are huge! You can change them:

  ```LaTeX
  \setlength{\topmargin}{-12.5mm}
  \setlength{\textheight}{250mm}
  \setlength{\hoffset}{-10mm}
  \setlength{\textwidth}{170mm}
  \setlength{\evensidemargin}{3.8mm}
  ```

* labelitemi: If you want to change the label of items (after the beginning of document!):

  ```LaTeX
  \renewcommand*{\labelitemi}{\MyLabel}
  ```

  You can do the same for enumerate environment:\n";

  ```LaTeX
  \renewcommand*{\labelenumi}{\arabic{enumi}.)}
  ```

* numberwithin: With big documents, you may want to have the numbered figures, tables, lists and so on numbered according to the chapter, section or whatever.
  You can use

  ```LaTeX
  \numberwithin{equation}{subsection}
  \numberwithin{figure}{chapter}
  ```

* tocdepth, secnumdepth: You can choose to which depth sections must be numbered and included in the TOC:

  ```LaTeX
  \setcounter{secnumdepth}{3}
  \setcounter{tocdepth}{2}
  ```

* graphicspath: If you have a lot of pictures to use and do not want to type the full path each time, you can use:

  ```LaTeX
  \graphicspath
  ```

* today: To display the date of the typesetting according to the babel settings, there is the command `\today`.
  You may be interested in the package `datetime2` (successor of `datetime` which is no longer supported).
* nocite: If you make a bibliography and want all the references to be displayed even if they were not quoted, you need `\nocite{*}`

### Deeper insights

* starred newcommand: If you are concerned about typesetting performances, prefer to use the starred version of (re)newcommand when the content does not have any newline.
* jobname: You can use the command `\jobname` to have the name of the current file displayed.
* multiple same footnotes: In case you want to write a footnote and reuse it for multiple occurences, you can define the following commands:

  ```LaTeX
  \newcommand{\FootnoteOne}[2]{\footnote{#2}\newcounter{#1}\setcounter{#1}{\value{footnote}} }
  \newcommand{\FootnoteRecall}[1]{\footnotemark[\value{#1}]}
  ```

* write package/class if not exists: If you need something in many files which is long and complicated to set up, you can write a package or a class.
  See the [LaTeX wikibooks](https://en.wikibooks.org/wiki/LaTeX/Creating_Packages)



## Matlab

* set(0): If you like your graphs in a way that is not the default way, there is a trick.
  You can set some options which will be used for all graphs you will make.
  These can be set through the command `set(0, 'property', 'value');`
  For instance, you can set the default color order for the plots, default font-size and style for axes, text, default marker size...
  To get the full list of properties available, simply run `get(0)`
* hsv: When doing plots with a variable number of lines, it may be helpful to use adaptable colors:

  ```matlab
  colors = hsv(N);%% for N plots
  for i = 1:N
      plot(x{i}, y{i}, 'color', colors(i, :));
  end
  ```

  Personnaly I prefer to use `hsv(N+2)`.
* enac tutorial: A good tutorial can be found on [ENAC EPFL](http://enacit1.epfl.ch/cours_matlab/),
  especially [the section about graphics](http://enacit1.epfl.ch/cours_matlab/graphiques.shtml).


## Miscellaneous

* Emacs is a great operating system - it lacks a good editor, though.
* GoogleEarth flight simulator F-16: In GoogleEarth there is a flight simulator.
  You can change the paramter of the plane in the file
  `$PATH_TO_GOOGLE/earth/free/resources/flightsim/aircraft/f16.acf`
  Thrust can be changed with parameters `P_max` and `F_max`.
  Maximum values advised are respectively 60e9 and 20e6.

