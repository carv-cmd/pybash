#!/bin/bash

# venv-mngr.sh: Create, activate/run, and upgrade python environments.

PROGNAME="${0##*/}"

PYVENVS="${HOME}/.py_venvs"
_PYBASH="${HOME}/bin/pybash"
_BASHPIP="${_PYBASH}/pip-mngr.sh"

Usage () {
	cat <<- EOF

${PROGNAME} - the stupid venv manager

usage: ${PROGNAME} [ -c | -r | -i | -u | -f ]  venv <script|pkg>

Examples:
  ${PROGNAME} [ -c | --create ] pyweb [ -i ] pip_pkgs
  ${PROGNAME} [ -r | --run ] pyweb scraper.py

 Where:
   --create  venv		=> Create new bare Python virtual environments (venvs).
   -c venv -i pkgs		=> Create venv and pip install packages in venv.
   -r venv script.py		=> Run 'script.python' in 'venv'.

# Sets up vcs for all new venvs in ~/.py_venvs_vcs.
# Option '-i <pkgs>' must immediately follow '-c venv' else use '~/bin/pippy'.

EOF
exit 1
}

Prog_error () {
	declare -A ERR
	ERR['nullArg']='no parameters passed'
	ERR['noPy']='script.py doest exist'
	ERR['noPkg']='pip install what package'
	ERR['venvDir']='~/py-envs doesnt exist'
	ERR['isVenv']='venv already exists'
	ERR['noVenv']='venv doesnt exist'
	ERR['pipLog']='~/py-envs/pip-logger doesnt exist or VCS is disabled'
	ERR['token']='unknown option token'

	echo -e "\nraised: ${ERR[${1}]}\n" 
	unset 'ERR'
	exit
}

Which_print () {
	echo -e "\nPY_VENV_PATH: $(which python3)"
}

Read_py_venvs () {
	# If reading operation; must find venv in ~/py-envs.
	local TARGET="${1}"
	local PY_SOURCE="${PYVENVS}/${TARGET}/bin/activate" 
	if [ -e "${PY_SOURCE}" ]; then 
		source "${PY_SOURCE}"
		Which_print
	else
		Prog_error 'noVenv'
	fi
}

Write_py_venvs () {
	# If writing; venv name must not already exist in ~/py-envs.
	local TARGET="${1}"
	[ -d "${PYVENVS}/${TARGET}" ] && 
		Prog_error 'isVenv'
}

Run_venvs () {
	# Verify python script exists.
	local _pyfile="${2}"
	if [ ! -e "${_pyfile}" ]; then
		Prog_error 'noPy'
	else
		# If pyscript and venv exists; un script in that venv.
		echo "Executing: '$(which python3) ${_pyfile}'"
		python3 "${_pyfile}"
	fi
}

Clobber_venv () {
	# TODO implement venv safe clobber
	echo "Clobbering Venv: ${1}"
}

Create_venvs () {
	python3 -m venv "${PYVENVS}/${TARGET}" && 
		"${_BASHPIP}" '-G' "${TARGET}" || 
		Prog_error 'venvDir'
}

Parse_args () {
	declare -A KWARGS
	local OPTION="${1}"; shift
	local TARGET="${1}"; shift

	case "${OPTION}" in
		-c | --create )
			Write_py_venvs "${TARGET}"
			Create_venvs "${TARGET}"
			;;
		-d | --delete )
			Read_py_venvs "${TARGET}" 
			Clobber_venv "${TARGET}"
			return 
			;;
		-r | --runpy )
			Read_py_venvs "${TARGET}" 
			Run_venvs "${TARGET}" "${2}"
			return 
			;;
		-h | --help )
			Usage
			;;
		* )
			Prog_error 'token'
			;;
	esac

	local PIPPY="${1}"; shift
	if [[ "${PIPPY}" == '-i' ]]; then 
		"${_BASHPIP}" '-i' "${TARGET}" "${@}"
	fi
}

# Passing no parameters fails immediately.
if [[ ! ${@} ]]; then
	Usage

# Check if ~/py-envs exists; else create directory.
elif [ ! -e "${PYVENVS}" ]; then
	mkdir "${PYVENVS}" || Prog_error 'venvDir'

else
	Parse_args "${@}"

fi



