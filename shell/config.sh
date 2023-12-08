#!/bin/sh
if [ -z ${vash+defined} ] || [ "$vash" = "" ]; then
    export vash="$HOME/.wash"
fi

export PATH="$PATH:$vash/bin:$vash/git/bin:$vash/perl:$vash/python"


screen_prompt_info() {
    if [ "$STY" = "" ]; then
        return
    fi

    # without session name: 637631.pts-4.ch03debian-gi
    #    with session name: 637758.swtF
    # So it is better to display just the middle part
    scr_id="${STY#*.}"
    echo "<${scr_id%.*}> "
}


vash()
{
    if [ $# -eq 0 ]; then
        cd "$vash" || exit 1
    else
        cd "$vash/$1*" || exit 1
    fi
}


ps2png()
{
    pstopnm -xborder=0 -yborder=0 "$1"
    pnmtopng "$1" > "$2"
}


splitPDF()
{
    pdftk "$1" burst
}
# Remove pages:
# pdftk myDocument.pdf cat 1-9 26-end output withoutRemovedPages.pdf (10-25)
# Merge:
# pdftk file1.pdf file2.pdf cat output newFile.pdf


psf()
{
    com="ps $1"
    shift;
    header=$($com | head -n 1)
    contents=$($com | grep -Ev grep | grep -E --color=always "$*")
    if [ "$contents" != "" ]; then
        echo "$header"
        echo "$contents"
    fi
}


# Needs this before lu:
alias du="du -h --max-depth=0"

lu() {
    # TODO posix glob
    if [ $# -eq 0 ]; then
        du ./.[^.]* ./* 2> /dev/null
        return
    fi

    if [ $# -eq 1 ] && [ "$1" = "-h" ]; then
        echo " Usage: lu [./% dir1 dir2...]"
        echo "   Displays the sizes of the elements of the current directory, or of dir1, dir2..."
        echo "   . : displays the sizes of each arguments"
        echo "   % : displays the sizes of the elements of each arguments"
        return
    fi

    type=$1
    shift
    for fileOrDir in "$@"; do
        if [ "$type" = "." ]; then
            du "$fileOrDir" 2> /dev/null

        elif [ "$type" = "%" ]; then
            # shellcheck disable=SC2086
            du "$fileOrDir" $fileOrDir/.[^.]* $fileOrDir/* 2> /dev/null

        else
            echo "Type not recognized..."
        fi
    done
}


alias cp="cp -r"
alias mv="mv -i"
alias scp="scp -r"
alias bc="bc -ql"
alias zip="zip -r"
alias who="who -bptuHT"
#alias shred="shred -vz --iterations=1"
alias df="df -h"
alias jobs="jobs -l"
alias ll="ls -lh"
alias grip="egrep -i --color=always"
alias gripHn="egrep -inH --color=always"
alias gripl="egrep -il --color=always"
alias grim="gripl --color=never"
alias vi="vim"
alias ex="vim"

scR() {
    screen -d -R "$*"
    screen -list
}
alias scL="screen -list"

alias psg="psf \"aux\""
alias psgu="psf \"-u \$USER\""
alias tree="tree -a"
alias forNum="echo \"for i in {1..10..2}\""


# Run on each login
who
scL
