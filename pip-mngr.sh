#!/bin/bash

# pip-mngr.sh: Pip manager, manager for sibling venv-mngr.sh.

PROGNAME="${0##*/}"
PYVENVS="${HOME}/.py_venvs"
PIP_LOGS="${HOME}/.py_venvs_vcs"

Usage () {
	cat <<- EOF

${PROGNAME} - the stupid venv pip manager

usage: ${PROGNAME} [ -i | -f | -G | -l | -u ]  venv pkgs

Examples:
  ${PROGNAME} [ -i | --install ] pyweb requests		= install requests in pyweb
  ${PROGNAME} [ -u | --uninstall ] pyweb requests	= uninstall requests from pyweb
  ${PROGNAME} [ -l | --list ] pyweb		= list all packages installed in pyweb
  ${PROGNAME} [ -f | --freeze ] pyweb	= generate a requireents.txt file from pyweb
  ${PROGNAME} [ -G | --git-freeze ] pyweb	= version control 'pyweb's env build files

# ${PROGNAME} keeps global site packages free of dependency collisions.

# Noting the odd option '${PROGNAME} [ -G | --git-freeze ] venv'.
# For use by venv-mngr.sh to track venv when created.
# Additionally, user can commit upgrades if not performed ${PROGNAME}.
# Calling '${PROGNAME} [ -f | --freeze ]' bypasses vcs and prints 

# These files are writen to the directory '~/py-envs/pip-logger'.
* Changes to these files are automatically version controlled w/ Git.

EOF
exit 1
}

Prog_error () {
	declare -A ERR
	ERR['nullArg']='no parameters passed'
	ERR['token']='unknown command line token'
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
	# If reading operation; must find venv in ~/py-envs.
	local PY_SOURCE="${PYVENVS}/${TARGET}/bin/activate" 
	if [ -e "${PY_SOURCE}" ]; then
		source "${PY_SOURCE}" || Prog_error 'noVenv'
		echo -e "\nactivated: $(which python3)"
	else
		Prog_error 'noVenv'
	fi
}

Git_freeze () {
	local COMMIT_MSG=
	local VENVDIR="${PIP_LOGS}/${TARGET}"

	[ ! -e "${VENVDIR}" ] && mkdir "${VENVDIR}"
	
	if [ -e "${VENVDIR}/requirements.txt" ]; then 
		# For existing, upgrades passed as commit msg.
		shift; FORMAT="\nEnv Modified: %s\nUpgraded: %s\n"
		printf -v COMMIT_MSG "${FORMAT}" "${TARGET}" "${ARGS}"
	else
		# Initial listing & requirement file names passed as commit msg.
		FORMAT="\nTrackingi New Venv: %s\n"
		printf -v COMMIT_MSG "${FORMAT}" "${TARGET}"
	fi

	# TODO remove
	echo 'skip vcs'; exit

	cd "${VENVDIR}"
	pip3 list > 'listing.txt'
	pip3 freeze > 'requirements.txt'
	git add 'listing.txt' 'requirements.txt'
	git commit -m "${COMMIT_MSG}"
	cd -
}

Pip_viewer () {
	Read_py_venvs "${TARGET}"  # Activate python venv before pip 'xyz'
	case "${1}" in
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
			pip3 show
			;;
		* )
			exit 1
	esac
}

Vcs_flags () {
	Chk_log_dir  # Check for VCS enabled directory
	Read_py_venvs "${TARGET}"  # Activate python venv before pip 'xyz'

	#set -x 
	if [[ "${VCSFLAG^}" == U ]]; then
		[ -z "${ARGS}" ] && 
			Prog_error 'nullArg'
		echo -e "\npip3 uninstall ${ARGS}"

	elif [[ "${VCSFLAG^}" == I ]]; then
		[ -z "${ARGS}" ] && 
			Prog_error 'nullArg'
		echo -e "\npip3 install ${ARGS}"
	fi

	echo -e "\nPip_freeze "${TARGET}" "${ARGS}"\n"
	#set +x
	
}

Parse_args () {
	local FLAG="${1}"; shift
	local TARGET="${1}"; shift
	local ARGS="${@}"
	local VCSFLAG=

	case "${FLAG}" in 
		-h | --help )
			Usage
			;;
		-[GIU] | --gfreeze | --install | --uninstall )
			TEMP_VAR="${FLAG##*-}"
			VCSFLAG="${TEMP_VAR:0:1}"
			Vcs_flags "${TARGET}" "${VCSFLAG}" "${ARGS}"
			;;
		-[cfls] | --check | --freeze | --list | --show )
			Pip_viewer "${FLAG}" "${TARGET}"
			;;
		* )
			Prog_error 'token'
			;;
	esac
}

if (( $# )); then
	Parse_args "${@}"
else
	Usage
fi
























