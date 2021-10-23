#!/bin/bash

# pybash-setup.sh: Create directories and verify resources exist

# Currently implemented with venv therefore limited to Python3+.
# Will implement virtualenv for building Python2 envs soon.


PY_VENVS="${HOME}/.py_venvs"
PY_VENVS_VCS="${HOME}/.py_venvs_vcs"

Py_venv_sanity_script () {
	cat <<- EOF

# Venv manager sanity test

from sys import base_prefix, executable, prefix

print("\nHello World\n")
print(f"Base_Prefix: {base_prefix}")
print(f"Venv_Prefix: {prefix}")
print(f"Python Executable: {executable}")
print("\nGoodbye World\n")
EOF
echo
}


# Create '~/.py_venvs' directory. (No vcs)
if [ ! -d "${PY_VENVS}" ]; then
	echo "mkdir: ${PY_VENVS}"
	mkdir "${PY_VENVS}" || exit 1 
fi

# Create 'sanitychk.py' script to run with `venvpy -r` option.
SANITY_CHK="${PY_VENVS}/sanitychk.py"
if [ ! -f "${SANITY_CHK}" ]; then
	echo "generating: ${SANITY_CHK}"
	Py_venv_sanity_script > "${SANITY_CHK}"
fi
unset 'SANITY_CHK'

# Create '~/.py_venvs_vcs' to mirror venv names from '~/.py_venvs'.
# All changes to python venvs are tracked when they are performed.
if [ ! -d "${PY_VENVS_VCS}" ]; then
	git init "${PY_VENVS_VCS}"

elif [ ! -d "${PY_VENVS_VCS}/.git" ]; then
	cd "${PY_VENVS_VCS}"
	git init .
	cd -
fi



