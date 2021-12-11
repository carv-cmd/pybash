#!/bin/bash 

sh_c='sh -c'
ECHO=${ECHO:-}
[ "$ECHO" ] && sh_c='echo'

PYVENVS=${PYVENVS:-~/.py_venvs}
PIP_LOGS=${PIP_LOGS:-~/.py_venvs_vcs}

VENV_NAME="$1"; shift
OPTION="$1"; shift
ARGS="$@"


Usage () {
    PROGNAME="${0##*/}"
    cat >&2 <<- EOF
the stupid venv pip manager

modify: $PROGNAME VENV_NAME [ -I | -U | -G | -F | -M ] PKG_NAME(s)
view: $PROGNAME [-c | -l | -s | -f ] VENV_NAME

Modify:
 --git-venv         Track VENV_NAME build files.
 -I, --install      Install PKG_NAME(s) in VENV_NAME.
 -U, --uninstall    Uninstall PKG_NAME(s) from VENV_NAME.
 -F, --use-file     Install from requirements.txt file.
 -M, --mk-files     Create requirements.txt from VENV_NAME

Inspect:
 -c, --check        Check VENV_NAME for broken dependencies.
 -l, --list         List all packages installed in VENV_NAME.
 -s, --show         Show information about PKG_NAME(s) in VENV_NAME.
 -f, --freeze       Pip freeze VENV_NAME to stdout.       
 -p, --pyvenvs      List all environments in PYVENVS.

EOF
exit 1
}

Error () {
    echo -e "error: $1\n" > /dev/stderr
    exit 1
}

read_py_venvs () {
    ACTIVATE_VENV="$PYVENVS/$VENV_NAME/bin/activate"
    if ! source "$ACTIVATE_VENV"; then
        Error "couldnt source: $VENV_NAME"
    fi
}

check_log_dir () {
    if [ ! -d "$PIP_LOGS/.git" ]; then
        git_init_pip_logs
    fi
}

git_init_pip_logs () {
    if ! $sh_c "git init $PIP_LOGS"; then
        Error 'no .py_venvs_vcs/.git'
    fi
}

pip_from_requirements () {
    [ ! -r "$ARGS" ] && Error "failed: requirements.txt ?= $ARGS"
    pip_action "install -r $ARGS"
}

pip_action () {
    local PIP_STRING="$1"
    if ! $sh_c "pip3 $PIP_STRING"; then
        Error "fatal: pip3 $PIP_STRING"
    fi
}

track_build () {
    COMMIT_MSG=
    if cd $PIP_LOGS; then
        [ ! -d "$VENV_NAME" ] && $sh_c "mkdir $VENV_NAME"
        commit_type
        add_build_files && make_commit
    fi
}

commit_type () {
    local COMMIT_TYPE='initial'
    [ -f "$VENV_NAME/requirements.txt" ] && FMT_MSG="modify"
    COMMIT_MSG="$COMMIT_TYPE: $VENV_NAME: $ARGS"
}

add_build_files () {
    cd "$VENV_NAME" || return 1
    echo -e "# $VENV_NAME\n" > README.md
    pip3 list > listing.txt
    pip3 freeze > requirements.txt
    cd - > /dev/null
}

make_commit () {
    git add . && git commit -m "$COMMIT_MSG"
}

###
pip_modify () {
    check_log_dir
    case "$OPTION" in
        --git-venv );;
        -I | --install ) pip_action "install $ARGS";;
        -F | --file ) pip_from_requirements "$ARGS";;
        -U | --uninstall ) pip_action "uninstall $ARGS";;
        -W | --wheel ) echo 'raise: NotImplementedError';;
        * ) Usage
    esac
    track_build
}

pip_views () {
    local run_pip=
    case "$OPTION" in
        -c | --check ) run_pip='check';;
        -f | --freeze ) run_pip='freeze';;
        -l | --list ) run_pip='list';;
        -s | --show ) run_pip="show $ARGS";;
        * ) Usage;;
    esac
    pip_action "$run_pip"
}

switch_case_names () {
    local TMP="$VENV_NAME"
    VENV_NAME="$OPTION"
    OPTION="$TMP"
}

list_venvs () {
    ls $PYVENVS
    exit
}

###
pip_mode='pip_modify'
if [[ "$VENV_NAME" =~ ^-{0,2}h(elp)?$ ]]; then
    Usage

elif [[ "$VENV_NAME" =~ ^-{0,2}p(yvenvs)?$ ]]; then
    list_venvs

elif [[ "$VENV_NAME" =~ ^--?(c|f|l|s|p) ]]; then
    switch_case_names
    pip_mode='pip_views'
fi

read_py_venvs "$VENV_NAME"
$pip_mode 

