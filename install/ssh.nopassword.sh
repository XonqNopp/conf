#!/bin/sh
# Copy public SSH key onto remote

# Check args and display
if [ "$#" = "0" ]; then
	echo " usage: $0 ssh_user_host [ssh_key_abs_filename]"
	return 8
fi

ssh=$1
echo "SSH: $ssh"

key="$HOME/.ssh/id_rsa"
if [ $# > 1 ]; then
	key=$2
fi
echo "key: $key"
if [ ! -f "$key" ]; then
	ssh-keygen << _EOF_
$key


_EOF_
fi

# Store the key
echo " Copying the public key"
cat $key.pub | ssh $ssh "mkdir -vp ~/.ssh; cat >> ~/.ssh/authorized_keys"

