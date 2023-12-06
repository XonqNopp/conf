#!/bin/bash

# PATH
export PATH="/usr/local/texlive/2021/bin/x86_64-linux:$PATH"

alias subu="ssh buildroot@localhost"

export testNetwork="10.64.75"

function sshpi() {
    ip=$1
    shift
    ssh "${testNetwork}.$ip" "$@"
}


#export swteam_env="f041c45fd771198c5e46035e89777e9829407558"


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

# MachuPicchu docking
export hsrcMaPiDoc="subprj/helios4/machu_picchu_docking_firmware"
heliosProject $hsrcMaPiDoc mpd

# Digimaster2
export hsrcDigi2="subprj/helios6/digimaster2_firmware"
heliosProject $hsrcDigi2 dg
