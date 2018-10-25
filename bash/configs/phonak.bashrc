#!/bin/bash

source ~/.wash/bash/bashrc

alias apt-proxy="sudo vim /etc/apt/apt.conf.d/99Proxy"
#export LD_LIBRARY_PATH=/media/sf_WS/helios/_build/protobuf-2.4.1/lib
export testNetwork="10.64.75"
export servicepi="pi@${testNetwork}.1"
alias dhcPi="ssh $servicepi cat DHCP.leases"

function sshpi() {
	ip=$1
	shift
	ssh ${testNetwork}.$ip "$@"
}

alias ssj="ssh continuous@ch03jenkins.corp.ads"
alias ssg="ssh root@ch03gitproxy.corp.ads"


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



# OneDrive
onedriveDir=$HOME/OneDrive
function mountOneDrive() {
	if [[ ! -d "$onedriveDir/backgrounds" ]]; then
		rclone --vfs-cache-mode writes mount SonovaOneDrive: $onedriveDir &
	fi
}




# Display on login
who

