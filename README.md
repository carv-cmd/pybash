# ~/bin/pybash

---
## Usage
Create, delete, and maintain basic python virtual environments on your Linux system.
Really just basic scripts to keep the global site package repositories free of user project dependencies.
Simple vcs implemented with Git, the scripts found in the gitbash repo can assist in pushing upstream.
As for now only venv is implemented but I will add virtualenv when the need for Python2.7 arises.
Pip is currently used for venv packaging, aiming for portability on a default install.
Anaconda will be implemented soon but that might get its own repo, we'll see. 
I assume the reader already has *~/bin* setup and the path variable included in their shell runtime.
If not google '*making ~/bin dir and setting path on >your-linux-distro<*' then proceed.

---
## Setup

Clone *pybash* into your ~/bin directory then run *pybash-setup.sh*.
  
*pybash-setup.sh* does the following:

1). `mkdir $HOME/.py_venvs`
* Local directory to isolate all python virtual environments for $USER

2). `git init $HOME/.py_venvs_vcs`
* Mirrors venv directories but instead tracks `(venv): pip3 {freeze,list}` files.
* A *README.md* is generated as well to note the venvs purpose.
* Example mirror directory structure: 
  * *pyweb/{README.md,requirements.txt,listing.txt}*

3). `echo '# Sanity Check ...' > $HOME/.py_venvs/sanitychk.py`
* Passing to *venv-mngr.sh* will return the executable *sanitychk.py* is running under.

4). Generate symlinks to pybash scripts from bin.

* Easier housekeeping for me, not sure if its the right way to do it though.

```
  [ ! -e $HOME/bin ] && mkdir $HOME/bin
  cd $HOME/bin
  ln -s ./pybash/venv-mngr.py venvpy
  ln -s ./pybash/pip-mngr.py pippy
```

---
## Scripts 

*pybash/venv-mngr.sh --> venvpy*
* Create new python venvs.
* Activate venvs then run python scripts in that virtual environment.

*pybash/pip-mngr.sh --> pippy*
* Has most of pips basic functionality built in, see --help
* ust handles environment switching for the user.
* Any successful changes to a venv generates new freeze and list files.
* These changes are then added and committed automatically to Git history.
* If you end up with broken dependencies, rebuild with last working venv/requirements.txt.
