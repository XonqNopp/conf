#!/bin/bash

source ~/.wash/bash/bashrc
alias vim="/usr/local/bin/vim"
export LD_LIBRARY_PATH=/media/sf_WS/helios/_build/protobuf-2.4.1/lib
export ww68="induni@192.168.3.3"
export testNetwork="10.64.75"
export pi="root@${testNetwork}.45"
export servicepi="pi@${testNetwork}.1"
alias dhcPi="ssh $servicepi cat DHCP.leases"
alias apt-proxy="sudo vim /etc/apt/apt.conf.d/99Proxy"
alias vimnotes="vim /media/sf_WS/notes.rst"
alias rsyncHelios="rsync -cv --delete --force --recursive --whole-file --stats --exclude *.pyc --exclude *.pyo --exclude _build --exclude obj --exclude __pycache__ --exclude _arc --exclude _archives --exclude _tools --exclude _prefix --exclude *.obj helios/ induni@192.168.3.3:/home/induni/helios/"

export servicepi="pi@${testNetwork}.1"
alias dhcPi="ssh $servicepi cat DHCP.leases"
function sshpi() {
	ip=$1
	shift
	ssh ${testNetwork}.$ip "$@"
}

function cpi() {
	byte=$1
	shift
	direction=$1
	shift
	if [ $direction == "2" ]; then
		where=$1
		shift
		scp "$@" ${testNetwork}.$byte:$where
		#echo "scp \"$@\" ${testNetwork}.$byte:$where"
	else
		where="."
		args=""
		for arg in $@; do
			args="$args ${testNetwork}.$byte:$arg"
		done
		scp $args $where
		#echo "scp $args $where"
	fi
}

export HTTP_PROXY="http://proxy.ch03.emea.corp.ads:8080"
export HTTPS_PROXY="http://proxy.ch03.emea.corp.ads:8080"
export http_proxy="http://proxy.ch03.emea.corp.ads:8080"
export https_proxy="http://proxy.ch03.emea.corp.ads:8080"

alias ssj="ssh continuous@ch03jenkins.corp.ads"
alias ssg="ssh root@ch03gitproxy.corp.ads"

export mediaWS="/media/sf_WS"
function ws() {
	if (( $# > 0 )); then
		cd $mediaWS/$1*
	else
		cd $mediaWS
	fi
}

