#!/bin/bash

# pip-mngr.sh: Pip manager, manager for sibling venv-mngr.sh.

PROGNAME="${0##*/}"
PYVENVS=~/.py_venvs
PIP_LOGS=~/.py_venvs_vcs


Usage () {
	cat <<- EOF

$PROGNAME - the stupid venv pip manager

usage: $PROGNAME [ -I | -U | -G | -c | -f | -l | -s ] VENV_NAME [ PKG_NAME(s) ]

==============================================================

Modifier Examples:
  ./$PROGNAME -I pyweb requests	= install requests in pyweb
  ./$PROGNAME -U pyweb requests	= uninstall requests from pyweb
  ./$PROGNAME -G pyweb		= version control 'pyweb's env build files

Viewer Examples:
  ./$PROGNAME -c pyweb		= check venv for broken dependencies
  ./$PROGNAME -l pyweb		= list all packages installed in pyweb
  ./$PROGNAME -f pyweb		= generate a requireents.txt file from pyweb
  ./$PROGNAME -s pyweb aiodns	= show information about installed packages

Dry-Run:
  DRY_RUN=true ./$PROGNAME -I pyweb requests

==============================================================
# $PROGNAME attempts to keep global site packages pristine.
* no guaruntees w/o warranty *

# The following pertains to: $PROGNAME [ -G | --git-freeze ] VENV
# -gfreeze main use by 'venv-mngr.sh' to setup vcs on creation.
# Additionally, changes made externally w/o $PROGNAME can be committed.
# These files are writen to the directory '~/py_venvs_vcs/\$VENV'.
# Pippy automatically commits any changes made to the assoiated build files.
# See comments in '${PROGNAME}.Git_freeze' for more details.

# Calling '$PROGNAME [ -f | --freeze ] VENV' sends requirements to stdout.

EOF
exit 1
}

Prog_error () {
	declare -A ERR
	ERR['nullArg']="no parameters passed\n`Usage`"
	ERR['token']="unknown command line token\n`Usage`"
	ERR['venvDir']='~/py-envs doesnt exist'
	ERR['noVenv']='venv doesnt exist'
	ERR['noPkg']='pip install what package'
	ERR['pipLog']="$PIP_LOGS doesnt exist or VCS is disabled"
	ERR['xPip']='pip (un)install failed'
	ERR['noSrc']='source error'
	echo -e "\nraised: ${ERR[${1}]}\n"
	unset 'ERR'
	exit 1
}

Chk_log_dir () {
	# Setup git-vcs dir to track venv requirements.txt changes.
	# Function should only continue to EOL one time.
	[ -e "${PIP_LOGS}/.git" ] && return 0

	# If dir exists but no vcs enabled; try git init PIP_LOGS.
	if [ -e "$PIP_LOGS" ]; then
		$sh_c "cd $PIP_LOGS" && $sh_c "git init" || 
			Prog_error 'pipLog'
	else
		$sh_c "git init $PIP_LOGS" && $sh_c "cd $PIP_LOGS" || 
			Prog_error 'pipLog'
	fi
	# TODO Checkout which branch ?
	# $sh_c "git checkout -b 'develop'"
	cd -
}

Read_py_venvs () {
	# Assign $ACTIVATOR w/ 'should-be-path' to venv activation script.
	# Assign $PYSRC 'should-be-path' venv executable path.
	local ACTIVATOR="${PYVENVS}/${TARGET}/bin/activate" 
	PYSRC="${PYVENVS}/${TARGET}/bin/python3"

	# If $ACTIVATOR found, source and export venv path executable.
	if [ -e "$ACTIVATOR" ]; then
		source "$ACTIVATOR" || Prog_error 'noSrc'
	else
		Prog_error 'noVenv'
	fi
}

Git_freeze () {
	# (Create/Use) ~/.py_venvs_vcs/$VENV for associated venv build/helper files.
	# In $VENV_VCS_DIR, the following files are generated and changes committed:
	# 1. 'README.md': include $VENV description/use-cases/etc.
	# 2. 'listing.txt': lists all packages in $VENV 
	# 3. 'requirements.txt': $VENV dependencies (rollback)
	local COMMIT_MSG=
	local VENVDIR="$PIP_LOGS/$TARGET"
	if [ ! -e "$VENVDIR" ]; then
		$sh_c "git init $VENVDIR" || Prog_error 'noVcs'
	fi
	
	# Msg output dependent on new or existing venvs
	[ ! -e "${VENVDIR}/requirements.txt" ] &&
		FMT_MSG="initial" || FMT_MSG="modify"
	printf -v COMMIT_MSG "$FMT_MSG: $FLAG: $TARGET: $ARGS"
	
	# Switch to venv-vcs dir and publish changes
	$sh_c "cd $VENVDIR && 
		echo \"# $TARGET\" > README.md && 
		pip3 list > listing.txt && 
		pip3 freeze > requirements.txt && 
		git add . && 
		git commit -m '${COMMIT_MSG}' && 
		cd -;
	"
}

Pip_mod_venvs () {
	# Check for VCS enabled logging directory + existing venv.
	Read_py_venvs "$TARGET"
	
	# Triple check correct env was activated before making changes.
	if [[ ! "$PYSRC" =~ $(which python3) ]]; then
		Prog_error 'noSrc'
	# If prior checks passed and --gfreeze was flag, return early.
	elif [[ "$FLAG" =~ ^(-G|--gfreeze)$ ]]; then
		return 0
	# Else un|install requires pkg arguments.
	elif [[ -z "$ARGS" ]]; then
		Prog_error 'nullArg'
	fi

	case "$FLAG" in 
		-I | --install )
			$sh_c "pip3 install $ARGS" || exit 1
			;;
		-U | --uninstall )
			$sh_c "pip3 uninstall $ARGS" || exit 1
			;;
		-W | --wheel )
			# TODO implement `pip3 wheel --requirement $ARGS`
			echo 'raise: NotImplementedError'
			exit 1
			;;
	esac
}

Pip_viewer () {
	# Activate venv, then pip <option>
	Read_py_venvs "$TARGET" 
	case "$FLAG" in
		-c | --check )  pip3 check ;;
		-f | --freeze )  pip3 freeze ;;
		-l | --list )  pip3 list ;;
		-s | --show )  pip3 show "$ARGS" ;;
	esac
}

Chk_option () {
	if [[ "$FLAG" =~ ^$2$ ]]; then
		return 0
	else
		return 1
	fi
}

Parse_args () {	
	local FLAG="$1"; shift
	local TARGET="$1"; shift
	local ARGS=${@}

	if Chk_option "$FLAG" '^-(h|-help)'; then
		Usage

	elif Chk_option "$FLAG" '-(-gfreeze|G|-install|I|-uninstall|U)'; then
		Pip_mod_venvs "$FLAG" "$TARGET" "$ARGS" &&
			Git_freeze "$FLAG" "$TARGET" "$ARGS" "$COMMIT_MSG"

	elif Chk_option "$FLAG" '-(-check|c|-freeze|f|-list|l|-show|s)'; then
		Pip_viewer "$FLAG" "$TARGET" "$ARGS"
	
	else	
		Prog_error 'token'
	fi
}

# Set env-variabale true to 'dry run' worker operations
if [ -n "$DRY_RUN" ] && "$DRY_RUN"; then
	sh_c='echo'
	set -x
else
	sh_c='sh -c'
fi

(( $# )) && Parse_args "$@" || Usage
unset 'PYSRC'

