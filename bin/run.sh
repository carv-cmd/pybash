#!/bin/bash

PYVENVS=${PYVENVS:-~/.py_venvs}
RUN_VENV="$PYVENVS/$1/bin/activate"; shift
PYFILE="$1"; shift
ARGS="$@"


Usage () {
    PROGNAME="${0##*/}"
    echo "usage: $PROGNAME PY_VENV PY_FILE" > /dev/stderr
}

Error () {
    echo -e "error: $1\n" > /dev/stderr
    exit 1
}

if [ ! -f "$RUN_VENV" ]; then
    Usage; Error "cant activate: $RUN_VENV"
elif [ ! -f "$PYFILE" ]; then
    Usage; Error "$PYFILE: doesn't exist"
fi

if source $RUN_VENV; then
    python3 $PYFILE $ARGS
fi

