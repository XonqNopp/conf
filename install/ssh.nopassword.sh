#!/bin/sh
##
## Check args and display
if [ $# = 0 ]; then
	echo " usage: $0 ssh_user_host"
	return 8
fi
ssh=$1
echo "SSH: $ssh"
##
## Check if id_rsa.pub exists
if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
	echo
	echo " Must run first ssh-keygen"
	echo " Please let the default value as they are"
	echo " Path should be ~/.ssh/id_rsa"
	echo " Passphrase empty"
	echo
	ssh-keygen
fi
##
## Store the key
echo " Copying the public key"
cat ~/.ssh/id_rsa.pub | ssh $ssh "mkdir -vp ~/.ssh; cat >> ~/.ssh/authorized_keys"
