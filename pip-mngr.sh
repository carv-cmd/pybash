#!/bin/bash

# pip-mngr.sh: Pip manager, manager for sibling venv-mngr.sh.

PROGNAME="${0##*/}"
PYVENVS="${HOME}/.py_venvs"
PIP_LOGS="${HOME}/.py_venvs_vcs"

#PIP_LOGS="${PYVENVS}/venv-vcs"

Usage () {
	cat <<- EOF

${PROGNAME} - the stupid pip-in-venv manager

usage: ${PROGNAME} [ -c | -r | -i | -u | -f ]  venv <script|pkg>

Examples:
  ${PROGNAME} [ -i | --install ] pyweb requests
  ${PROGNAME} [ -u | --uninstall ] pyweb requests
  ${PROGNAME} [ -f | --freeze ] pyweb

 Where:
   --install  venv pkgs 	= Install one or more packages into venv with pip.
   --uninstall  venv pkgs	= Uninstall one or more packages from venv with pip.
   --freeze  venv		= pip freeze venv-requirements.txt.

* Omitting[-r]; All options generate name-{pip list, pip freeze}.txt files.
* These files are writen to the directory '~/py-envs/pip-logger'.
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
	#ERR['noGit']=''

	echo -e "\npip-raised: ${ERR[${1}]}" 
	unset 'ERR'
	exit 1
}

Read_py_venvs () {
	# If reading operation; must find venv in ~/py-envs.

	set -x  # TODO remove
	#echo -e "\ncur-venv: $(which python3)\n" || 
	#[[ "$(echo "$(which python3)" | grep "${TARGET}")" ]] && return 0
	echo "$(grep "${TARGET}" <<< $(which python3))"

	#echo "$(echo "$(which python3)" | grep "${TARGET}")"

	set +x  # TODO remove

	local PY_SOURCE="${PYVENVS}/${TARGET}/bin/activate" 
	if [ -e "${PY_SOURCE}" ]; then
		source "${PY_SOURCE}" && 
			echo -e "\nactivated: $(which python3)\n" || 
			Prog_error 'noVenv'
	else
		Prog_error 'noVenv'
	fi
}

Chk_log_dir () {
	# Setup git-vcs dir to track venv requirements.txt changes.
	# Function should only continue to EOL one time.
	# If ~/py-envs/PIP_LOGS/.git exists; return 0.
	[ -e "${PIP_LOGS}/.git" ] &&
		echo "pip_logs/.git exists" && return 0

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

Pip_freeze () {

	local COMMIT_MSG=
	local VENVDIR="${PIP_LOGS}/${TARGET}"

	[ ! -e "${VENVDIR}" ] && mkdir "${VENVDIR}"
	
	set -x  # TODO remove
	if [ -e "${VENVDIR}/requirements.txt" ]; then 
		# For existing, upgrades passed as commit msg.
		shift; FORMAT="\nEnv Modified: %s\nUpgraded: %s\n"
		printf -v COMMIT_MSG "${FORMAT}" "${TARGET}" "${*}"
	else
		# Initial listing & requirement file names passed as commit msg.
		FORMAT="\nTrackingVenv: %s\n* listing.txt && requirements.txt *"
		printf -v COMMIT_MSG "${FORMAT}" "${TARGET}"
	fi
	set +x  # TODO remove

	echo "Commit Msg: ${COMMIT_MSG}"
	exit

	cd "${VENVDIR}"
	pip3 list > 'listing.txt'
	pip3 freeze > 'requirements.txt'
	git add 'listing.txt' 'requirements.txt'
	git commit -m "${COMMIT_MSG}"
	cd -
}

Parse_args () {
	set -x  # TODO remove

	echo ${@}
	echo "${@}"

	local FLAG="${1}"; shift
	local TARGET="${1}"; shift
	local ARGS="${@}"
	local FREEZE_IT=
	set +x  # TODO remove

	Chk_log_dir  # Check for VCS enabled directory
	Read_py_venvs "${TARGET}"  # Activate python venv before pip 'xyz'

	set -x  # TODO remove
	case "${FLAG}" in 
		-h | --help )
			Usage 
			;;
		-G | --git-venv )
			FREEZE_IT=1
			;;
		-i | --install )
			echo -e "\npip3 install ${ARGS}\n"
			FREEZE_IT=1
			;;
		-u | --uninstall )
			echo -e "\npip3 uninstall ${ARGS}\n"
			FREEZE_IT=1
			;;
		-f | --freeze )
			pip freeze
			;;
		-l | --list )
			pip list
			;;
		-s | --show )
			pip show
			;;
		* )
			Prog_error 'token'
			;;
	esac

	if [[ "${FREEZE_IT}" ]]; then
		Pip_freeze "${TARGET}" "${ARGS}"
	fi

	set +x  # TODO remove
}

Parse_args "${@}"

























