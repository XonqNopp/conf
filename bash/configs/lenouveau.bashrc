#!/bin/bash

# shellcheck source=./bash/bashrc
source $HOME/.wash/bash/bashrc

export MANPATH="$MANPATH:/usr/local/texlive/2017/texmf-dist/doc/man"
export INFOPATH="$INFOPATH:/usr/local/texlive/2017/texmf-dist/doc/info"
export PATH="$PATH:/usr/local/texlive/2017/bin/x86_64-linux"

