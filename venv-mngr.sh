#!/bin/bash

# venv-mngr.sh: Create, activate/run, and upgrade python environments.

PROGNAME="${0##*/}"

PYVENVS="${HOME}/.py_venvs"
BASHPIP="${HOME}/bin/pybash/pip-mngr.sh"

Usage () {
	cat <<- EOF

${PROGNAME} - the stupid venv manager

usage: 
  ${PROGNAME} [ -C | --create ] venv [ -i ] pkgs
  ${PROGNAME} [ -r ]  venv pyfile.py

 Where:
   --create  venv		=> Create new bare Python virtual environments (venvs).
   -C venv -i pkgs		=> Create venv and pip install packages in venv.
   -r venv script.py		=> Run 'script.python' in 'venv'.

# Sets up vcs for all new venvs in ~/.py_venvs_vcs.
# Option '-i <pkgs>' must immediately follow '-c venv'.
# To modify venvs after creation use 'pip-mngr.sh' (~/bin/pippy)

EOF
exit 1
}

Prog_error () {
	declare -A ERR
	ERR['nullArg']='no parameters passed'
	ERR['token']='unknown option token'
	ERR['yesErr']="Enter 'yes' to clobber"
	ERR['venvDir']='~/.py_venvs doesnt exist'
	ERR['noVenv']='venv doesnt exist'
	ERR['noPy']='script.py doest exist'
	ERR['pipLog']='~/.py_venvs_vcs doesnt exist'
	ERR['noPkg']='pip install what package'

	echo -e "\nraised: ${ERR[${1}]}\n" >&2
	unset 'ERR'
	exit 1
}

Run_venvs () {
	# Activate venv and run file.py in venv. 
	local PY_SOURCE="${TARGET}/bin/activate" 
	local PY_FILE="${ARG}"
	
	# Verify python virtual environment exists else print usage
	[ ! -e "${PY_SOURCE}" ] && 
		Usage >&2
	
	# Verify python script exists ($PYFILE <<< $ARG), else exit 1.
	[[ -n "${PY_FILE}" && -e "${PY_FILE}" ]] || 
		Usage >&2
	
	# Equivlent to `$PY_SOURCE $PY_FILE`.
	source "${PY_SOURCE}"
	python3 "${PY_FILE}"
}

Create_venvs () {
	# Generate new python virtual enviroments under ~/.py_venvs directory.
	# Venv build files are tracked with git under ~/.py_venvs_vcs/mirror_name.
	# If venv/directory name already exists; prompt before clobbering that venv.
	# Use 'pip-mngr.sh' for all post creation venv upgrades.

	if [ ! -d "${TARGET}" ]; then	
		python3 -m venv "${TARGET}"
	else
		read -p "Clobber existing venv: ${TARGET##*/}? (yes/no)"
		case "${REPLY}" in 
			yes ) 
				python3 -m venv --clear "${TARGET}"
				;;
			y ) 
				Prog_error 'yesErr'
				;;
			* )
				exit 1
		esac
	fi
	if [[ ! "${ARG}" == '-i' ]]; then 
		${BASHPIP} '-G' "${TARGET##*/}"
	else
		${BASHPIP} '-I' "${TARGET##*/}" "${POSITS}" || {
			cd "${TARGET%%/*}" && rm -r "${TARGET##*/}"; 
		}
	fi 
}

Parse_args () {
	local OPTION="${1}"; shift
	local TARGET="${PYVENVS}/${1}"; shift
	local ARG="${1}"; shift
	local POSITS="${@}"
	case "${OPTION}" in
		-C | --create )
			Create_venvs "${TARGET}" "${ARG}" "${POSITS}"
			;;
		-r | --runpy )
			Run_venvs "${TARGET}" "${ARG}"
			;;
		-h | --help )
			Usage
			;;
		* )
			Prog_error 'token'
			;;
	esac
}

# Passing no parameters fails immediately.
if [[ ! ${@} ]]; then
	Usage
# Check if ~/py-envs exists; else create directory.
elif [ ! -e "${PYVENVS}" ]; then
	mkdir "${PYVENVS}" || 
		Prog_error 'venvDir'
fi

Parse_args "${@}"

