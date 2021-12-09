#!/bin/bash

# make-sanitychk.sh: Create python sanity test, use w/ `venvpy run VENV_NAME sanitychk.py`


PYVENVS=${PYVENVS:-~/.py_venvs}
SANITY_CHK="$PYVENVS/sanitychk.py"


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

echo "Generating: ${SANITY_CHK}"
if ! sh -c "set -C; Py_venv_sanity_script > $SANITY_CHK"; then
    echo 'make `santiychk.py` failed'
else
    ls $PYVENVS
fi

