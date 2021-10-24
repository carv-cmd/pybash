#!/bin/bash

# pip-mngr.sh: Pip manager, manager for sibling venv-mngr.sh.

PROGNAME="${0##*/}"
PYVENVS="${HOME}/.py_venvs"
PIP_LOGS="${HOME}/.py_venvs_vcs"

Usage () {
	cat <<- EOF

${PROGNAME} - the stupid venv pip manager

usage: ${PROGNAME} [ -I | -U | -G | -c | -f | -l | -s ]  venv pkgs

Examples:
  ${PROGNAME} [ -I ] pyweb requests	= install requests in pyweb
  ${PROGNAME} [ -U ] pyweb requests	= uninstall requests from pyweb
  ${PROGNAME} [ -G ] pyweb		= version control 'pyweb's env build files
  ${PROGNAME} [ -c ] pyweb		= check venv for broken dependencies
  ${PROGNAME} [ -l ] pyweb		= list all packages installed in pyweb
  ${PROGNAME} [ -f ] pyweb		= generate a requireents.txt file from pyweb
  ${PROGNAME} [ -s ] pyweb requests	= show information about installed packages

# ${PROGNAME} keeps global site packages pristine.

# Noting the odd option '${PROGNAME} [ -G | --git-freeze ] venv'.
# For use by venv-mngr.sh to track venv when created.
# Additionally, user can commit upgrades if not performed ${PROGNAME}.
# Calling '${PROGNAME} [ -f | --freeze ]' bypasses vcs and prints 
# These files are writen to the directory '~/py-envs/pip-logger'.
# Changes to these files are automatically version controlled w/ Git.

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
	ERR['pipLog']='$PIP_LOG doesnt exist or VCS is disabled'
	ERR['xPip']='pip (un)install failed'
	echo -e "\nraised: ${ERR[${1}]}\n"
	unset 'ERR'
	exit 1
}

Chk_log_dir () {
	# Setup git-vcs dir to track venv requirements.txt changes.
	# Function should only continue to EOL one time.
	# If ~/py-envs/PIP_LOGS/.git exists; return 0.
	[ -e "${PIP_LOGS}/.git" ] && 
		return 0

	# If dir exists but no vcs enabled; try git init PIP_LOGS.
	if [ -e "${PIP_LOGS}" ]; then
		cd "${PIP_LOGS}" && git init || 
			Prog_error 'pipLog'
	else
		git init "${PIP_LOGS}" && cd "${PIP_LOGS}" || 
			Prog_error 'pipLog'
	fi

	# Checkout main branch 
	git checkout -b 'main'
	cd -
}

Read_py_venvs () {
	local ACTIVATOR="${PYVENVS}/${TARGET}/bin/activate" 

	if [ -e "${ACTIVATOR}" ]; then
		source "${ACTIVATOR}"
		[[ "${PYSRC}" =~ "$(which python3)" ]] || 
			Prog_error 'srcErr'
	else
		Prog_error 'noVenv'
	fi
}

Git_freeze () {
	local COMMIT_MSG=
	local VENVDIR="${PIP_LOGS}/${TARGET}"

	[[ "${PYSRC}" =~ "$(which python3)" ]] || 
		Prog_error 'srcErr'

	[ ! -e "${VENVDIR}" ] && 
		mkdir "${VENVDIR}"
	
	if [ ! -e "${VENVDIR}/requirements.txt" ]; then 
		# Initial listing & requirement file names passed as commit msg.
		FORMAT="\nFreeze/List -> %s\n"
		printf -v COMMIT_MSG "${FORMAT}" "${TARGET}"
	else
		# For existing, upgrades passed as commit msg.
		FORMAT="\nModified -> %s\nPipped( %s ): %s\n"
		printf -v COMMIT_MSG "${FORMAT}" "${TARGET}" "${FLAG}" "${ARGS}"
	fi

	cd "${VENVDIR}"
	pip3 list > 'listing.txt'
	pip3 freeze > 'requirements.txt'
	git add 'listing.txt' 'requirements.txt'
	git commit -m "${COMMIT_MSG}"
	cd -
}

Pip_mod_venvs () {
	# Check for VCS enabled logging directory and existing venv.
	Chk_log_dir && 
		Read_py_venvs "${TARGET}" || 
		Prog_error 'noVenv'
	
	[[ "${PYSRC}" =~ "$(which python3)" ]] || 
		Prog_error 'srcErr'

	case "${FLAG}" in 
		-I | --install )
			set -x
			[ -z "${ARGS}" ] && Prog_error 'nullArg'
			pip3 install ${ARGS} || exit 1
			set +x
			;;
		-U | --uninstall )
			[ -z "${ARGS}" ] && Prog_error 'nullArg'
			pip3 uninstall ${ARGS} || exit 1
			;;
		-W | --wheel )
			echo "pip3 wheel --requirement ${ARGS}"
	esac

	Git_freeze "${FLAG}" "${TARGET}" "${ARGS}" 
}

Pip_viewer () {
	Read_py_venvs "${TARGET}" || Prog_error 'noVenv'
	case "${FLAG}" in
		-c | --check )
			pip3 check
			;;
		-f | --freeze )
			pip3 freeze
			;;
		-l | --list )
			pip3 list
			;;
		-s | --show )
			pip3 show "${ARGS}"
			;;
	esac
	echo
}

Parse_args () {
	local FLAG="${1}"; shift
	local TARGET="${1}"; shift
	local ARGS=${@}
	PYSRC="${PYVENVS}/${TARGET}/bin/python3"

	case "${FLAG}" in 
		-h | --help )
			Usage
			;;
		-[GIU] | --gfreeze | --install | --uninstall )
			Pip_mod_venvs "${FLAG}" "${TARGET}" "${ARGS}"
			;;
		-[cfls] | --check | --freeze | --list | --show )
			Pip_viewer "${FLAG}" "${TARGET}" "${ARGS}"
			;;
		* )
			Prog_error 'token'
			;;
	esac
	unset 'PYSRC'
}

if (( $# )); then
	Parse_args "${@}"
else
	Usage
fi



