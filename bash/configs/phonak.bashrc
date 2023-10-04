#!/bin/bash

source "$HOME/.wash/bash/bashrc"

# PATH
export PATH="/usr/local/texlive/2021/bin/x86_64-linux:$PATH"

alias apt-proxy="sudo vim /etc/apt/apt.conf.d/99Proxy"

alias subu="ssh buildroot@localhost"

export testNetwork="10.64.75"

function sshpi() {
	ip=$1
	shift
	ssh "${testNetwork}.$ip" "$@"
}


export workspace="$HOME/workspace"
export swt="$workspace/swt"
export helios="$workspace/helios"


# PROXY
export SONOVA_PROXY_URL="proxy.ch03.emea.corp.ads"
export SONOVA_PROXY_PORT="8080"



# transfer
export tg="/mnt/ch03transfer/13ginduni"
alias tgi="cd \$tg && ll"

# OneDrive
onedriveDir=$HOME/OneDrive
function mountOneDrive() {
	if [[ ! -d "$onedriveDir/backgrounds" ]]; then
		rclone --vfs-cache-mode writes mount SonovaOneDrive: "$onedriveDir" &
	fi
}


# SWT
export venv="/home/induni/workspace/swt/_venv"
export swtVenv="$venv/default"
export vPy="$swtVenv/bin/python"
alias vPep8="\$vPy -m pep8 . --exclude=env,docs,helpers/software/corti/andromeda,framework,_* --max-line-length=120 --ignore=E221,E265,E266,E722,E402,W391,W503"
alias vPylint="\$vPy -m pylint --score=no --persistent=no --reports=no --ignore=env,docs,andromeda,framework --notes=FIXME --rcfile=/home/induni/workspace/swt/framework/pylintrc"
alias vPylintF="vPylint devices generic.py helpers remote run.py scripts ssh swt_env.py templates tests utils common"
alias vSphinx="\$swtVenv/bin/sphinx-build -W -b html"
function bSphinx() {
	vSphinx "$*" "$*/_build/html"
}
export swteam_env="f041c45fd771198c5e46035e89777e9829407558"


# Helios
export rhpimpl="rhp/RhpAppImpl"
function heliosProject() {
	directory=$1
	shortname=$2
	eval "function vim${shortname}() { vim -o $directory/\$@; }"
	eval "function vim${shortname}r() { vim -o $directory/$rhpimpl/\$@; }"
	eval "function vim${shortname}ru() { vim -o $directory/rhp/unit_test/\$@; }"
	eval "function vim${shortname}o() { vim -o $directory/overlays/\$@; }"
}

# MachuPicchu
export hsrcMaPi="subprj/helios4/machu_picchu_firmware"
heliosProject $hsrcMaPi mp

function vimmpg() {
	guiDir="$hsrcMaPi/gui"
	if [ "$#" = "0" ]; then
		vim $guiDir
	else
		vim $guiDir/$1*
	fi
}

# MachuPicchu docking
export hsrcMaPiDoc="subprj/helios4/machu_picchu_docking_firmware"
heliosProject $hsrcMaPiDoc mpd

# Digimaster2
export hsrcDigi2="subprj/helios6/digimaster2_firmware"
heliosProject $hsrcDigi2 dg

# BB
export hsrcBB="src/building_blocks"

function vimbb() {
	if [ "$#" = "0" ]; then
		vim $hsrcBB
	else
		vim $hsrcBB/$1*
	fi
}

function vimbbg() {
	if [ "$#" = "0" ]; then
		vim gui_events
	else
		vim gui_events/$1*
	fi
}

function vimbbgu() {
	if [ "$#" = "0" ]; then
		vim gui_events/unit_test
	else
		vim gui_events/unit_test/$1*
	fi
}



# To do file
export todoFile="$HOME/.todos"

function todo() {
	echo "* $*" >> "$todoFile"
}

function todos() {
	if [ "$(wc -l "$todoFile" | cut -d' ' -f1)" = "0" ]; then
		return
	fi

	echo "TODO:"
	cat "$todoFile"
}

alias vimtodos="vim \$todoFile"


# Display on login
who
scL
echo
todos
