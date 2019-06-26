#!/bin/bash

source ~/.wash/bash/bashrc

# latex
export PATH="$PATH:/usr/local/texlive/2018/bin/x86_64-linux"

alias apt-proxy="sudo vim /etc/apt/apt.conf.d/99Proxy"

#export LD_LIBRARY_PATH=/media/sf_WS/helios/_build/protobuf-2.4.1/lib

alias subu="su buildroot"

export testNetwork="10.64.75"
export servicepi="pi@${testNetwork}.1"
alias dhcPi="ssh $servicepi cat DHCP.leases"

export PYTHON_DIR="/usr/lib/python3.5"

function sshpi() {
	ip=$1
	shift
	ssh ${testNetwork}.$ip "$@"
}

alias ssj="ssh continuous@ch03jenkins.corp.ads"
alias ssg="echo /var/lib/docker/volumes/gitlab_data/_data/git-data/repositories; ssh swteam@ch03rdteam.phonak.com"

alias scR="screen -RR"


# PROXY
export SONOVA_PROXY_URL="http://proxy.ch03.emea.corp.ads"
export SONOVA_PROXY_PORT="8080"
export HTTP_PROXY="$SONOVA_PROXY_URL:$SONOVA_PROXY_PORT"
export HTTPS_PROXY="$SONOVA_PROXY_URL:$SONOVA_PROXY_PORT"
export http_proxy="$SONOVA_PROXY_URL:$SONOVA_PROXY_PORT"
export https_proxy="$SONOVA_PROXY_URL:$SONOVA_PROXY_PORT"

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

# OneDrive
onedriveDir=$HOME/OneDrive
function mountOneDrive() {
	if [[ ! -d "$onedriveDir/backgrounds" ]]; then
		rclone --vfs-cache-mode writes mount SonovaOneDrive: $onedriveDir &
	fi
}


export venv="/home/induni/workspace/swt/_venv"
export swtVenv="$venv/default"
export vPy="$swtVenv/bin/python"
alias vPep8="$vPy -m pep8 . --exclude=env,docs,helpers/software/corti/andromeda,framework,_* --max-line-length=119 --ignore=E221,E265,E266,E722,E402,W391,W503"
alias vPylint="$vPy -m pylint --score=no --persistent=no --reports=no --ignore=env,docs,andromeda,framework --enable=wrong-import-order,fixme,missing-docstring,empty-docstring,blacklisted-name,invalid-name,undefined-variable,unused-variable,unused-import,unused-argument,notimplemented-raised,unexpected-line-ending-format,consider-iterating-dictionary,syntax-error,parse-error,exec-used,eval-used,bad-indentation,mixed-indentation,print-statement,multiple-imports,ungrouped-imports,wrong-import-position,bad-super-call,not-callable,assignment-from-no-return,unexpected-keyword-arg,redundant-keyword-arg,repeated-keyword,bad-format-character,truncated-format-string,mixed-format-string,format-needs-mapping,missing-format-string-key,too-many-format-args,too-few-format-args,bad-format-string-key,unused-format-string-key,bad-format-string,missing-format-argument-key,unused-format-string-argument,format-combined-specification,missing-format-attribute,invalid-format-index,consider-merging-isinstance,simplifiable-if-statement,simplify-boolean-expression,inconsistent-return-statements,unnecessary-pass,unnecessary-lambda,deprecated-lambda,unnecessary-semicolon,relative-import,unused-wildcard-import,backtick,raw_input-builtin,unicode-builtin,xrange-builtin,trailing-whitespace,superfluous-parens --notes=FIXME --rcfile=/home/induni/workspace/swt/framework/pylintrc"
alias vPylintF="vPylint devices generic.py helpers remote run.py scripts ssh swt_env.py templates tests utils"
alias vSphinx="$swtVenv/bin/sphinx-build -W -b html"
function bSphinx() {
	vSphinx "$@" "$@/_build/html"
}



export todoFile="$HOME/.todos"

function todo() {
	echo "* $@" >> $todoFile
}
alias todos="cat $todoFile"
alias vimtodos="vim $todoFile"

# Display on login
who
echo
echo "TODO:"
todos

