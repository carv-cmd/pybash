#!/bin/bash

PYVENVS=${PYVENVS:-~/.py_venvs}

RUN_VENV="$PYVENVS/$1/bin/activate"; shift
ARGS="$@"


Usage () {
    PROGNAME="${0##*/}"
    echo "usage: $PROGNAME PY_VENV PY_FILE" > /dev/stderr
}

Error () {
    echo -e "error: $1\n" > /dev/stderr
    exit 1
}

find_venv () {
    if [ -f "$RUN_VENV" ]; then
        return 0
    else
        return 1
    fi
}


if [ ! -f "$RUN_VENV" ]; then
    Usage; Error "cant activate: $RUN_VENV"
elif source $RUN_VENV; then
    python3 $ARGS
fi

