#!/bin/bash

# TeXlive (debian)
export PATH="/usr/local/texlive/2021/bin/x86_64-linux:$PATH"

# Python scripts (WSL)
export PATH="$PATH:/mnt/c/Python310-32/Scripts"

# PHP mess detector (WSL)
export PATH="$PATH:/home/induni/phpmd/src/bin"


alias subu="ssh buildroot@localhost"

export g="ch03debian-gi.corp.ads"
export gIP="10.64.66.153"
alias sg="ssh \$g"

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


# Helios {{{
export heliosHome="$HOME/workspace/helios/helios"

function hVpy() { $heliosHome/_build/venv_python310/Scripts/python.exe $@; }
function hBuild() { python3 build.py $@; }
function hBuildCpp() { hBuild --modules=cppcheck $@; }
function hClean() { hBuild -t clean $@; }
function hCode() { hBuild -p pc/code_style_checker $@; }
function hPylint() { hBuild -p pc/semiautomated_pylint $@; }
function hCopy() { hCode && hPylint; }

function huTests() {
    target="debug"
    if [ "$1" = "clean" ]; then
        target="$1"
        shift
    fi

    # Feed the desired modules on which to run unittest
    hBuild -t "$target" -p pc/unit_test_shared_bb/custom -x --modules cppcheck,$*;
}

function hAffected() { python3 ci/affected_projects.py --target_branch='upstream/master' $@; }

# Tracer for shannon {{{
export H_SHANNONTX_VERSION="1.2.0"
export H_BB_SHANNON="src/building_blocks/shannon"
export H_BB_SHANNON_RELEASES_TO3="$H_BB_SHANNON/app_files/TO3"
export H_BB_SHANNON_TX="$H_BB_SHANNON_RELEASES_TO3/shannonTX"

function hshTracerTx() {
    hVpy \
        \$H_BB_SHANNON_TX/trace_decoder/python/launch_traces_decoding.py \
        \$H_BB_SHANNON_TX/\$H_SHANNONTX_VERSION/python/ \
        \$H_BB_SHANNON_TX/trace_decoder \
        COM\$UART_COM \
        \$H_BB_SHANNON_TX/\$H_SHANNONTX_VERSION/apps/shannon_tx \
        "$(tracerFilename shannonTx)"
}

function hshTraceControlMaPiDm() { hoMaPi shannonSetDebugModule --params='0D;01'; }
function hshTraceControlMaPiTx() { hoMaPi shannonSetDebugModule --params='27;01'; }
# }}}

# Helios helper {{{
function hhBuild() { hBuildCpp -p pc/heliosHelper $@; }
function hhClean() { hClean -p pc/heliosHelper $@; }
function hh() { obj/pc/heliosHelper/release/heliosHelper.exe $@; }
function hhReboot() { hh --cmd=reboot $@; }

function hhDB() {
    filename="$1"
    symbol="$2"
    value="$3"
    cmd="read"
    if [ "$value" != "" ]; then
        cmd="write"
    fi

    hh --input="$filename" --cmd="${cmd}_database" --symbol="$symbol" --value="$value"
}
# }}}

# Tracer {{{
export UART_COM_HOME=5
export UART_COM_MURTEN_BLUE=3
export UART_COM_MURTEN_RED=4
export UART_COM="$UART_COM_HOME"

function uartMurtenBlue() { export UART_COM="$UART_COM_MURTEN_BLUE"; }
function uartMurtenRed() { export UART_COM="$UART_COM_MURTEN_RED"; }

function hTracer() {
    COM_UART=$1
    shift
    hVpy tools/scripts/tracer/trace_decoder.py -p "COM$COM_UART" --forceColors --ignoreCheck --forceOneLine $@;
}

function hTraceControl() { hVpy tools/scripts/tracer/trace_controller.py $@; }

function tracerFilename() {
    directory="_traces/$1"
    mkdir -p "$directory"
    echo "$directory/$1_$(date +%Y%m%d_%H%M%S_%N).log"
}
# }}}

# Generate variables and commands {{{
# HomoCalib {{{
function heliosProjectHomoCalib() {
    heliosIndex="$1"
    name="$2"
    shortname="$3"
    variant="$4"

    suffix=""
    if [ "$variant" = "C" ]; then
        suffix="sha_calib"
    elif [ "$variant" = "H" ]; then
        suffix="homologation"
    elif [ "$variant" = "Hdm" ]; then
        suffix="homo_dm"
    elif [ "$variant" = "Hbt" ]; then
        suffix="homo_bt"
    fi

    # Build
    hProject="hProject_$name$variant"
    export "$hProject"="-p helios$heliosIndex/${name}_$suffix"
    eval "function hb$shortname$variant() { hBuildCpp ${!hProject} && hhBuild \$@; }"
    eval "function hc$shortname$variant() { hClean ${!hProject} \$@; }"

    fw="fw$shortname$variant"
    export "$fw"="obj/helios$heliosIndex/${name}_$suffix/release/${name}_$suffix.helios"

    eval "function hOk$shortname$variant() { hCode && hDox$shortname && hb$shortname$variant \$@; }"

    # Install
    eval "function hh$shortname$variant() { hh --input=${!fw} \$@; }"
    eval "function hi$shortname$variant() { hh$shortname$variant --cmd=upload \$@; }"
    eval "function hbi$shortname$variant() { hb$shortname$variant && hi$shortname$variant \$@; }"
    eval "function hpbi$shortname$variant() { git pull && hbi$shortname$variant \$@; }"

    # USB commands
    eval "function ho$shortname$variant() { overlay=\$1; shift; hh$shortname$variant --cmd=overlay --overlay_cmd=\$overlay \$@; }"
    eval "function hh${shortname}${variant}Dump() { hh$shortname$variant --cmd=dump_database \$@; }"
    eval "function hh${shortname}${variant}DB() { hhDB ${!fw} \$@; }"

    # Tracer
    eval "function ht$shortname$variant() { hTracer \$UART_COM -f ${!fw} -o \$(tracerFilename ${name}_$suffix) \$@; }"
    eval "function htc$shortname$variant() { hTraceControl -f ${!fw} \$@; }"
}
# }}}


function heliosProject() {
    heliosIndex="$1"
    name="$2"
    shortname="$3"
    homo="$4"
    homoDM="$5"
    homoBT="$6"
    calib="$7"

    # Doc
    eval "function hDox$shortname() { hBuild -p doc/doxygen_$name --modules=disable_debug_print,final_release,enable_simple_error_screen,cppcheck \$@; }"
    eval "function hDocSemi$shortname() { hBuild -p doc/semiautomated_sphinx --custom_args $name \$@; }"

    # Build
    hProject="hProject_$name"
    export "$hProject"="-p helios$heliosIndex/${name}_firmware"
    eval "function hb$shortname() { hBuildCpp ${!hProject} && hhBuild \$@; }"
    eval "function hc$shortname() { hClean ${!hProject} \$@; }"

    hProjectBL="hProject_${name}BL"
    export "$hProjectBL"="-p helios$heliosIndex/${name}_bootloader"
    eval "function hb${shortname}BL() { hBuildCpp ${!hProjectBL} \$@; }"
    eval "function hc${shortname}BL() { hClean ${!hProjectBL} \$@; }"

    fw="fw$shortname"
    export "$fw"="obj/helios$heliosIndex/${name}_firmware/release/${name}_firmware.helios"

    eval "function hOk$shortname() { hCode && hDox$shortname && hb$shortname \$@; }"

    # Unittest RHP
    eval "function hu${shortname}Init() { py python_run.py 'subprj/pc/unit_test_shared_bb/common/generate_test.py -p $name -m obj/helios$heliosIndex/${name}_firmware/release/modules.h' \$@; }"
    eval "function hcu$shortname() { hBuild -t clean -p pc/unit_test_shared_bb/helios$heliosIndex/$name --modules=cppcheck,lcov \$@; }"
    eval "function hu$shortname() { hBuild -t debug -p pc/unit_test_shared_bb/helios$heliosIndex/$name -x --modules=cppcheck,lcov \$@; }"
    eval "function hbu$shortname() { hb$shortname && hu$shortname; }"

    # Install
    eval "function hh$shortname() { hh --input=${!fw} \$@; }"
    eval "function hi$shortname() { hh$shortname --cmd=upload \$@; }"
    eval "function hbi$shortname() { hb$shortname && hi$shortname \$@; }"
    eval "function hpbi$shortname() { git pull && hbi$shortname \$@; }"

    # USB commands
    eval "function ho$shortname() { overlay=\$1; shift; hh$shortname --cmd=overlay --overlay_cmd=\$overlay \$@; }"
    eval "function hh${shortname}Dump() { hh$shortname --cmd=dump_database \$@; }"
    eval "function hh${shortname}DB() { hhDB ${!fw} \$@; }"

    # Tracer
    eval "function ht$shortname() { hTracer \$UART_COM -f ${!fw} -o \$(tracerFilename $name) \$@; }"
    eval "function htc$shortname() { hTraceControl -f ${!fw} \$@; }"

    if [ "$homo" = "1" ]; then
        heliosProjectHomoCalib "$heliosIndex" "$name" "$shortname" H
    fi

    if [ "$homoDM" = "1" ]; then
        heliosProjectHomoCalib "$heliosIndex" "$name" "$shortname" Hdm
    fi

    if [ "$homoBT" = "1" ]; then
        heliosProjectHomoCalib "$heliosIndex" "$name" "$shortname" Hbt
    fi

    if [ "$calib" = "1" ]; then
        heliosProjectHomoCalib "$heliosIndex" "$name" "$shortname" C
    fi
}
# }}}

# Products {{{
# MachuPicchu {{{
heliosProject 4 machu_picchu MaPi 1 0 0 1

function huGuiEv() { huTests bb_gui_events $@; }
function hcuGuiEv() { huTests clean bb_gui_events $@; }

function hshMaPi() { hhMaPi --cmd=read_database --symbol=ShannonCalibrationData; }
function hshMaPiW() { hhMaPi --cmd=write_database --symbol=ShannonCalibrationData --value="$1"; }
function hshMaPiXX() { hshMaPiW "00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00;00"; }
function hshMaPi22() { hshMaPiW "07;5f;7e;06;00;42;0d;10;20;1f;a9;07;41;b3;67;00;16;17;23;2c;00;00;00;00;00;16;00;00;10;10;18;cc"; }
function hshMaPi90() { hshMaPiW "07;5f;7e;06;00;43;0f;0f;1f;1e;a8;08;50;a3;66;00;18;18;22;2c;00;00;00;00;00;5a;00;00;10;10;18;a6"; }
function hshMaPi95() { hshMaPiW "07;5f;7e;06;00;44;0e;11;22;21;a9;06;50;a3;67;00;18;19;21;2b;00;00;00;00;00;5f;00;00;10;10;18;fc"; }

function hhMaPiProdOn() { hhMaPiDB ProductName '52;6f;67;65;72;20;4f;6e;00;00;00;00;00;00;00;00' && hhMaPiDB ShannonParameterSet '00;00' && hhReboot; }
function hhMaPiProdOnIn() { hhMaPiDB ProductName '52;6f;67;65;72;20;4f;6e;20;69;4E;00;00;00;00;00' && hhMaPiDB ShannonParameterSet '01;00' && hhReboot; }

# MachuPicchu DOCKING
heliosProject 4 machu_picchu_docking MaPiDoc 0 0 0 0

# }}}

# Digimaster2 {{{
heliosProject 6 digimaster2 Digi2 0 1 1 1
#alias hshDigi2='hhDigi2 --cmd=read_database --symbol=ShannonCalibrationData'
function hhDigi2Prod5() { hhDigi2DB ProductName '35;30;30;30;20;56;32;00;00;00;00;00;00;00;00;00' && hhReboot; }
function hhDigi2Prod7() { hhDigi2DB ProductName '37;30;30;30;20;56;32;00;00;00;00;00;00;00;00;00' && hhReboot; }

# Shannon
function hshDigi2Write() {
    hhDigi2DB ShannonCalibrationData "$1"
    hhDigi2DB Shannon2ndCalibrationData "$2"
}

export hDigi2DefaultShannonCalibration='07;5f;7e;06;00;48;0e;0e;24;20;a8;08;50;a3;61;00;16;17;1f;28;00;00;00;00;00;07;00;00;10;10;18;36'
function hshDigi2Default() { hshDigi2Write "$hDigi2DefaultShannonCalibration" "$hDigi2DefaultShannonCalibration"; }
function hshDigi2_108() { hshDigi2Write "07;5f;7e;06;00;42;10;0e;21;1e;a9;08;40;a3;6b;00;17;17;20;29;00;00;00;00;00;6c;00;00;10;10;18;56" "07;5f;7e;06;00;45;0f;0f;20;1e;a9;06;20;b2;66;00;18;18;27;29;00;00;00;00;00;6c;00;00;10;10;18;75"; }
function hshDigi2_113() { hshDigi2Write "07;5f;7e;06;00;40;0f;0e;1f;1d;98;08;40;a2;6a;00;18;18;1e;29;00;00;00;00;00;71;00;00;10;10;18;fd" "07;5f;7e;06;00;44;11;0d;1c;1d;a8;08;30;a2;67;00;17;17;20;2b;00;00;00;00;00;71;00;00;10;10;18;e1"; }
function hshDigi2_119() { hshDigi2Write "07;5f;7e;06;00;44;10;0d;24;20;a8;07;40;a2;6a;00;18;18;23;26;00;00;00;00;00;77;00;00;10;10;18;f3" "07;5f;7e;06;00;43;10;0e;22;22;a8;09;30;a3;68;00;17;17;26;29;00;00;00;00;00;77;00;00;10;10;18;e2"; }

# Shannon traces
export H_BB_SHANNON_DIGI2="$H_BB_SHANNON_RELEASES_TO3/digimaster2"
export H_SHANNON_DIGI2_VERSION="0.5.9"
function hshTracerDigi2Common() {
    # WARNING: not working in WSL - use ConEmu
    hVpy \
        \$H_BB_SHANNON_DIGI2/trace_decoder/python/launch_traces_decoding.py \
        \$H_BB_SHANNON_DIGI2/\$H_SHANNON_DIGI2_VERSION/python/ \
        \$H_BB_SHANNON_DIGI2/trace_decoder \
        COM\$UART_COM \
        \$H_BB_SHANNON_DIGI2/\$H_SHANNON_DIGI2_VERSION/apps/digimaster2_$1 \
        $(tracerFilename shannon_$1)
}
function hshTracerDigi2Roger() { hshTracerDigi2Common roger; }
function hshTracerDigi2A2dp() { hshTracerDigi2Common a2dp; }
function hshTraceConfigRogerDm() { hoDigi2 shannonSetDebugModule --params='01;0D;01'; }

# Digimaster2 GUI SoundfieldClient
function hgdEdit() { ./_venv/Scripts/pyside2-designer.exe src/soundfield_client/resources/main_view.ui ; }
function hgdCompile() { ./_venv/Scripts/pyside2-uic.exe src/soundfield_client/resources/main_view.ui -o src/soundfield_client/views/main_view_ui.py ; }
function hgdCheck() { ./_venv/Scripts/python.exe -m pre_commit run --all-files ; }
function hgdRun() { ./_venv/Scripts/python.exe -m src.soundfield_client.app $@ ; }
function hgdDoc() { ./_venv/Scripts/python.exe create_exe.py soundfield_client --doc ; }
function hgdZip() { ./_venv/Scripts/python.exe create_exe.py soundfield_client --zip ; }
function hgdRelease() { ./_venv/Scripts/python.exe create_exe.py soundfield_client --release --zip ; }
# }}}

# Titania/Seattle {{{
heliosProject 2 titania_microphone TiM 0 0 0 0
heliosProject 2 titania_passaround TiP 0 0 0 0
heliosProject 2 titania_hub TiH 0 0 0 0
heliosProject 2 titania_repeater TiR 0 0 0 0
function hoTiMCustomEq() { params=$1; shift; hoTim hlcDigimasterManualCustomEq --params="$params" $@; }
# }}}
# }}}
# }}}
