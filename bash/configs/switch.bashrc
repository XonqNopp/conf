if [ "$SSH_TTY" ]; then
	source $HOME/.wash/bash/runcom/original.bashrc
fi
export PS1="$yellow\t $lightblue\u$nc@$lightred\h$nc: $lightpurple\W $nc$ "
##
## Consider git fetch/pull on login?
