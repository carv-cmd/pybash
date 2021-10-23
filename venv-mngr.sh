#!/bin/bash

# venv-mngr.sh: Create, activate/run, and upgrade python environments.

PROGNAME="${0##*/}"

PYVENVS="${HOME}/.py_venvs"

_PYBASH="${HOME}/bin/pybash"
_BASHPIP="${_PYBASH}/pip-mngr.sh"
_ACTIVATE="${_PYBASH}/venv-activator.sh"

#_PIP_LOG_DIR="${PYVENVS}/pip-logger"
#export PROGNAME PYVENVS _PIP_LOG_DIR 

Usage () {
	cat <<- EOF

${PROGNAME} - the stupid venv manager

usage: ${PROGNAME} [ -c | -r | -i | -u | -f ]  venv <script|pkg>

Examples:
  ${PROGNAME} [ -c | --create ] pyweb
  ${PROGNAME} [ -r | --run ] pyweb scraper.py
  ${PROGNAME} [ -i | --install ] pyweb requests
  ${PROGNAME} [ -u | --uninstall ] pyweb requests
  ${PROGNAME} [ -f | --freeze ] pyweb

 Where:
   --create  venv		=> Create new Python virtual environments (venvs).
   --run  venv script.py	=> Run 'script.python' in 'venv'.
   --install  venv pkgs 	=> Install one or more packages into venv with pip.
   --uninstall  venv pkgs	=> Uninstall one or more packages from venv with pip.
   --freeze  venv		=> pip freeze venv-requirements.txt.

* Omitting[-r]; All options generate name-{pip list, pip freeze}.txt files.
* These files are writen to the directory '~/py-envs/pip-logger'.
* Changes to these files are automatically version controlled w/ Git.

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
	echo -e "\n_PY_VENV_PATH: \033[38;5;201m $(which python3) \033[00m"
}

Read_py_venvs () {
	# If reading operation; must find venv in ~/py-envs.
	local TARGET="${1}"
	local PY_SOURCE="${PYVENVS}/${TARGET}/bin/activate" 
	if [ -e "${PY_SOURCE}" ]; then 
		#source "${PY_SOURCE}/bin/activate"
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

Create_venvs () {
	python3 -m venv "${PYVENVS}/${TARGET}" && 
		"${_BASHPIP}" --git-freeze "${TARGET}" || 
		Prog_error 'venvDir'
}

Main_loop () {
	set -x  # TODO remove

	local TARGET="${KWARGS['target']}"
	local PIPS="${KWARGS['pips']}"
	local ARGS="${KWARGS['args']}"

 	if [[ ${KWARGS['mode']} == 'W' ]]; then
		Write_py_venvs "${TARGET}"
		Create_venvs "${TARGET}"
	else
		if [[ ! "${PIPS}" ]]; then 
			Read_py_venvs "${TARGET}" 
			Run_venvs "${TARGET}" "${ARGS}"
		else
			# ~/bin/pippy <flag> <venv> <pkgs>
			"${_BASHPIP}" "${PIPS}" "${TARGET}" "${ARGS[@]}"
		fi
	fi

	set +x  # TODO remove
}

Parse_args () {
	declare -A KWARGS

	KWARGS['option']="${1}"; shift
	KWARGS['target']="${1}"; shift
	KWARGS['args']="${@}"
	KWARGS['mode']=

	case "${KWARGS['option']}" in
		-c | --create )
			KWARGS['mode']='W'
			;;
		-i | --install )
			KWARGS['pips']='-i'
			;;
		-r | --runpy )
			;;
		-h | --help )
			Usage
			;;
		* )
			Prog_error 'token'
			;;
		#-u | --uninstall )
		#	KWARGS['pips']='-u'
		#	;;
	esac
	Main_loop "${KWARGS[@]}"
}

# Passing no parameters fails immediately.
if [[ ! "${@}" ]]; then
	Usage

# Check if ~/py-envs exists; else create directory.
elif [ ! -e "${PYVENVS}" ]; then
	mkdir "${PYVENVS}" || Prog_error 'venvDir'

else
	Parse_args "${@}"

fi



