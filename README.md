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
* Mirrors venv directories but instead tracks '(venv): pip3 {freeze,list}' files.
* A README.md is generated as well if the user would like to 
* Example mirror: pyweb/{README.md,requirements.txt,listing.txt}

Generate python script, *$HOME/.py_venvs/sanitychk.py*
* Passing to *venv-mngr.sh* will return the executable *sanitychk.py* is running under.

## Scripts 

pybash/venv-mngr.sh --> venvpy
* Create new python venvs.
* Activate venvs then run python scripts in that virtual environment.

pybash/pip-mngr.sh --> pippy
* Most of pips basic functionality, just handles environment switching for the user.
* Any successful changes to a venv generates new freeze and list files.
* These changes are then added and committed automatically to Git history.
* If you end up with broken dependencies, rebuild with last working venv/requirements.txt.

