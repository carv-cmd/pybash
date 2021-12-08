#!/bin/bash

PYVENVS=~/.py_venvs
VENV_NAME="$PYVENVS/$1/bin/activate"; shift
PYFILE="$1"; shift
ARGS="$@"


Usage () {
    PROGNAME="${0##*/}"
    echo "usage: $PROGNAME PY_VENV PY_FILE" >&2
}

Error () {
    echo -e "error: $1\n" > /dev/stderr
    exit 1
}

if [ ! -f "$VENV_NAME" ]; then
    Usage; Error "cant activate: $VENV_NAME"
elif [ ! -f "$PYFILE" ]; then
    Usage; Error "$PYFILE: doesn't exist"
fi

if source $VENV_NAME; then
    python3 $PYFILE $ARGS
fi

