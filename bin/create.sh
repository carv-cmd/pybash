#!/bin/bash


sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

PYVENVS=${PYVENVS:-~/.py_venvs}
PIP_LOGS=${PIP_LOGS:-~/.py_venvs_vcs}
BASHPIP=~/bin/pybash/bin/pips.sh

VENV_NAME="$1"; shift
OPTION="$1"; shift
ARGS="$@"


Usage () {
    PROGNAME="${0##*/}"
    cat <<- EOF
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

setup_tracking () { 
    $sh_c "$BASHPIP -G $VENV_NAME"
}

pip_install () {
    $sh_c "$BASHPIP $VENV_NAME -I $ARGS"
}

pip_requirements () {
    check_requirements_file
    $sh_c "$BASHPIP $VENV_NAME -F $ARGS"
}

check_requirements_file () {
    if [ ! -f "$ARGS" ]; then
        Error "$ARGS: doesn't exist"
    fi
}


[[ "$OPTION" =~ ^-(I|F|-clear)$ ]] && CLEAR='--clear'
catch_overwrites
create_environment
setup_tracking

if [[ "$OPTION" =~ ^--?(I|i(nstall)?)$ ]]; then
    pip_install
elif [[ "$OPTION" =~ ^--?(F|f(ile)?)$ ]]; then
    pip_requirements
fi

