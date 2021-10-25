# ~/bin/pybash

Create, delete, and maintain basic python virtual environments on your Linux system.
Really just basic scripts to keep the global site package repositories free of user project dependencies.
Simple vcs implemented with Git, the scripts found in the gitbash repo can assist in pushing upstream.
As for now only venv is implemented but I will add virtualenv when the need for Python2.7 arises.
Pip is currently used for venv packaging, aiming for portability on a default install.
Anaconda will be implemented soon but that might get its own repo, we'll see. 

## Setup

*pybash-setup.sh* does the following:

mkdir *$HOME/.py_venvs*
* Local directory to isolate all python virtual environments for $USER

git init *$HOME/.py_venvs_vcs*
* Mirrors venv directories but contain listing and requirement files.

Generate python script, *$HOME/.py_venvs/sanitychk.py*
* Passing to *venv-mngr.sh* will return the executable *sanitychk.py* is running under.

