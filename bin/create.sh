#!/bin/bash

BASHPIP=~/bin/pybash/bin/pips.sh

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

PYVENVS=${PYVENVS:-~/.py_venvs}
PIP_LOGS=${PIP_LOGS:-~/.py_venvs_vcs}
export ECHO PYVENVS PIP_LOGS

VENV_NAME="$1"; shift
OPTION="$1"; shift
ARGS="$@"


Usage () {
    PROGNAME="${0##*/}"
    cat >&2 <<- EOF
The stupid venv manager
usage: venvpy ${PROGNAME%.*} VENV_NAME [ --install PKGS | --file file.txt ]
force: venvpy ${PROGNAME%.*} VENV_NAME [ --clear ][ -I PKGS | -F file.txt ]

Options:
 -f, --file         Build VENV_NAME from requirements.txt file.
 -i, --install      Install PKGS when creating VENV_NAME.

EOF
exit 1
}

Error () {
    echo -e "error: $1\n" > /dev/stderr
    exit 1
}

catch_overwrites () {
    valid_venv
    if [ -d "$PYVENVS/$VENV_NAME" -a ! "$CLEAR" ]; then	
        Error "use: $VENV_NAME [--clear]|[-I][-F] ARGS"
    fi
}

valid_venv () {
    if [ ! "$VENV_NAME" ]; then
        Error 'null: $VENV_NAME'
    fi
}

create_environment () {
    if ! $sh_c "python3 -m venv $CLEAR $PYVENVS/$VENV_NAME"; then
        Error "create $VENV_NAME failed"
    fi
}

pip_install_pkgs() {
    $sh_c "$BASHPIP $VENV_NAME -I $ARGS"
}

pip_requirements () {
    requirements_exist
    $sh_c "$BASHPIP $VENV_NAME -F $ARGS"
}

requirements_exist () {
    if [ ! -f "$ARGS" ]; then
        Error "$ARGS: doesn't exist"
    fi
}


[[ "$OPTION" =~ ^-(I|F|-clear)$ ]] && CLEAR='--clear'
catch_overwrites
create_environment

if [[ "$OPTION" =~ ^--?(I|i(nstall)?)$ ]]; then
    pip_install_pkgs
elif [[ "$OPTION" =~ ^--?(F|f(ile)?)$ ]]; then
    pip_requirements
fi

