#!/bin/bash

# Custom scripts
PATH="$PATH:$HOME/.wash/phonak/bin"
PATH="$PATH:$HOME/workspace/helios/helios/tools/bin"
PATH="$PATH:$HOME/workspace/apollo/apollo/script/bin"

# TeXlive (debian)
PATH="/usr/local/texlive/2021/bin/x86_64-linux:$PATH"

# Python scripts (WSL)
PATH="$PATH:/mnt/c/Python310-32/Scripts"

# PHP mess detector (WSL)
PATH="$PATH:$HOME/phpmd/src/bin"

export PATH


alias subu="ssh buildroot@localhost"

export wx="ch03wxctbltx3.corp.ads"
export g="ch03debian-gi.corp.ads"
export gIP="10.64.66.153"
alias sg="ssh -X \$wx"

export testNetwork="10.64.75"

function sshpi() {
    ip=$1
    shift
    ssh "${testNetwork}.$ip" "$@"
}


#export swteam_env="f041c45fd771198c5e46035e89777e9829407558"


function fix_vpn_mtu() {
    echo "Fix VPN MTU (sudo)..."
    sudo ip link set dev eth0 mtu 1400
}


function fix_screen_init() {
    echo "Fix screen init (sudo)..."
    sudo /etc/init.d/screen-cleanup start
}


# Digimaster2 GUI SoundfieldClient
function hgdEdit() { ./_venv/Scripts/pyside2-designer.exe src/soundfield_client/resources/main_view.ui ; }
function hgdCompile() { ./_venv/Scripts/pyside2-uic.exe src/soundfield_client/resources/main_view.ui -o src/soundfield_client/views/main_view_ui.py ; }
function hgdCheck() { ./_venv/Scripts/python.exe -m pre_commit run --all-files ; }
function hgdRun() { ./_venv/Scripts/python.exe -m src.soundfield_client.app $@ ; }
function hgdDoc() { ./_venv/Scripts/python.exe create_exe.py soundfield_client --doc ; }
function hgdZip() { ./_venv/Scripts/python.exe create_exe.py soundfield_client --zip ; }
function hgdRelease() { ./_venv/Scripts/python.exe create_exe.py soundfield_client --release --zip ; }
