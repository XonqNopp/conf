#!/bin/bash

if [ "$SSH_TTY" ]; then
	# shellcheck source=./bash/bashrc
	source "$HOME/.wash/bash/bashrc"

	export PS1="${yellow:?}\t ${lightblue:?}\u${nc:?}@${lightred:?}\h${nc:?}: ${lightpurple:?}\W ${nc:?}$ "
fi

