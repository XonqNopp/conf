#!/bin/bash

source "$HOME/.wash/bash/bashrc"

# latex
export PATH="$PATH:/usr/local/texlive/2018/bin/x86_64-linux"

alias apt-proxy="sudo vim /etc/apt/apt.conf.d/99Proxy"

#export LD_LIBRARY_PATH=/media/sf_WS/helios/_build/protobuf-2.4.1/lib

alias subu="ssh buildroot@localhost"

export testNetwork="10.64.75"
export servicepi="pi@${testNetwork}.1"
alias dhcPi="ssh \$servicepi cat DHCP.leases"

export PYTHON_DIR="/usr/lib/python3.5"

function sshpi() {
	ip=$1
	shift
	ssh "${testNetwork}.$ip" "$@"
}

alias ssj="ssh continuous@ch03jenkins.corp.ads"
alias ssg="echo /var/lib/docker/volumes/gitlab_data/_data/git-data/repositories; ssh swteam@ch03rdteam.phonak.com"

alias scR="screen -xRR"

export workspace="$HOME/workspace"
export swt="$workspace/swt"
export helios="$workspace/helios"


# PROXY
export SONOVA_PROXY_URL="proxy.ch03.emea.corp.ads"
export SONOVA_PROXY_PORT="8080"
#export http_proxy="$SONOVA_PROXY_URL:$SONOVA_PROXY_PORT"
#export https_proxy="$SONOVA_PROXY_URL:$SONOVA_PROXY_PORT"
#export HTTP_PROXY=$http_proxy
#export HTTPS_PROXY=$https_proxy
#export FTP_PROXY=$ftp_proxy
#export NO_PROXY=$no_proxy

#gsettings set org.gnome.system.proxy mode 'manual'
#gsettings set org.gnome.system.proxy.http host $SONOVA_PROXY_URL
#gsettings set org.gnome.system.proxy.http port $SONOVA_PROXY_PORT
#gsettings set org.gnome.system.proxy.https host $SONOVA_PROXY_URL
#gsettings set org.gnome.system.proxy.https port $SONOVA_PROXY_PORT
#gsettings set org.gnome.system.proxy.ftp host $SONOVA_PROXY_URL
#gsettings set org.gnome.system.proxy.ftp port $SONOVA_PROXY_PORT
#gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8']"



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


# Helios
alias vimmp='vim subprj/helios4/machu_picchu_firmware/'
alias vimmpr='vim subprj/helios4/machu_picchu_firmware/rhp/RhpAppImpl/'
alias vimmprb='vim subprj/helios4/machu_picchu_firmware/rhp/RhpAppImpl/BatteryControllerImpl.cpp'
alias vimmprd='vim subprj/helios4/machu_picchu_firmware/rhp/RhpAppImpl/DSPControllerImpl.cpp'
alias vimmprm='vim subprj/helios4/machu_picchu_firmware/rhp/RhpAppImpl/MainControllerImpl.cpp'
alias vimmpru='vim subprj/helios4/machu_picchu_firmware/rhp/RhpAppImpl/UserInterfaceControllerImpl.cpp'
alias vimmprw='vim subprj/helios4/machu_picchu_firmware/rhp/RhpAppImpl/WirelessControllerImpl.cpp'
alias vimmpg='vim subprj/helios4/machu_picchu_firmware/gui/'
alias vimmpad='vim subprj/helios4/machu_picchu_firmware/adapters/'
alias vimmpap='vim subprj/helios4/machu_picchu_firmware/approot/'
alias vimmpc='vim subprj/helios4/machu_picchu_firmware/config/'
alias vimmpo='vim subprj/helios4/machu_picchu_firmware/overlays/'
alias vimbb='vim src/building_blocks/'
alias vimbbg='vim src/building_blocks/gui_events/'
alias vimbbgu='vim src/building_blocks/gui_events/unit_test/'


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
echo
todos

