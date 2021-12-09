#!/bin/bash

# venv-mngr.sh: Create, activate/run, and upgrade python environments.
# Generate new python virtual enviroments under ~/.py_venvs directory.
# Venv build files are tracked with git under ~/.py_venvs_vcs/mirror_name.
# If venv/directory name already exists; prompt before clobbering that venv.
# Use 'pip-mngr.sh' for all post creation venv upgrades.


sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

PYBIN=${PYBIN:-~/bin/pybash/bin}
PYVENVS=${PYVENVS:-~/.py_venvs}
PIP_LOGS=${PIP_LOGS:-~/.py_venvs_vcs}
export ECHO PYBIN PYVENVS PIP_LOGS

SUBCMD="$1"; shift
ARGS="$@"


Usage () {
    PROGNAME="${0##*/}"
    cat <<- EOF
The stupid venv manager
$PROGNAME create VENV_NAME [ --install PKG_NAME(s) | --file requirements.txt ]
$PROGNAME [run] VENV_NAME PYTHON_SCRIPT
$PROGNAME pips --help 

Subcommands:
 create     Create new Python virtual environment VENV_NAME.
 pips       Pip install PKG_NAME(s) in VENV_NAME.
 run        Activate VENV_NAME then run PYFILE.
 sanity     Make $PYVENVS/sanitychk.py file.
 help       Print this help message and exit.

EOF
exit 1
}

Error () {
    echo -e "error: $1\n" > /dev/stderr
    exit 1
}

try_defaults () {
    DEFAULT_DIRS=( $PYVENVS $PIP_LOGS )
    for defs in ${DEFAULT_DIRS[@]}; do
        [ ! -d "$defs" ] && make_defaults "$defs"
    done
}

make_defaults () { 
    if ! $sh_c "mkdir $defs"; then
        Error "make $defs failed"
    fi
}

valid_subcmd () {
    if [[ "$SUBCMD" =~ ^-(-?h(elp)?)$ ]]; then
        Usage
    elif [ -f "$SUBCMD" ]; then
        Error "invalid subcmd: $SUBCMD"
    fi
}


valid_subcmd
try_defaults
$PYBIN/$SUBCMD.sh $ARGS 

