#!/bin/sh

#### parameters

SBCL_VER=1.2.7
SBCL_ARCH=x86-64-linux
SBCL_NAME="sbcl-${SBCL_VER}-${SBCL_ARCH}"
SBCL_URL="http://prdownloads.sourceforge.net/sbcl/${SBCL_NAME}-binary.tar.bz2?use_mirror=autoselect"

LOCAL_LISP_TREE=${HOME}/common-lisp
QL_HOME=${HOME}/quicklisp

#### shell environment

set -ev

export SBCL_HOME="${HOME}/lib/sbcl"
export PATH="${HOME}/bin${PATH:+:}${PATH}"
export CL_SOURCE_REGISTRY="${TRAVIS_BUILD_DIR}//:${LOCAL_LISP_TREE}//${CL_SOURCE_REGISTRY:+:}${CL_SOURCE_REGISTRY}"

export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_RUNTIME_DIR="${HOME}"
mkdir -m 0700 -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"

export DISPLAY=":99.0" # cf. travis.yml

alias curl='curl -# -L'
alias sbcl='sbcl --noinform --no-sysinit --no-userinit --disable-debugger'

#### install system deps

sudo apt-get install python-software-properties
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu vivid main universe" -y
sudo apt-get update -yy
sudo apt-get --no-upgrade install libgtk-3.0 libwebkit2gtk-4.0-dev libsoup2.4-dev

#### bootstrap clisp

# sudo apt-get install clisp

# cat >"${HOME}/clisp-wrapper.lisp" <<EOF
# (load "${QL_HOME}/setup.lisp")
# (ql:quickload (list "cl-webkit2" "cl-webkit2-tests"))
# (load "./demo/simple-browser.lisp")
# (ext:exit)
# EOF

#### bootstrap SBCL

curl "$SBCL_URL" | tar -xjf -
(cd "$SBCL_NAME" && INSTALL_ROOT="$HOME" sh ./install.sh)

#### bootstrap quicklisp

curl http://beta.quicklisp.org/quicklisp.lisp -o ./quicklisp.lisp
sbcl --load ./quicklisp.lisp --eval '(quicklisp-quickstart:install)' --quit

#### install lisp dependencies

mkdir -p "$LOCAL_LISP_TREE"

#### run

sbcl --load "${QL_HOME}/setup.lisp" --eval '(ql:quickload (list "cl-webkit2" "cl-webkit2-tests"))' --quit
sbcl --load "${QL_HOME}/setup.lisp" --load ./demo/simple-browser.lisp --eval '(simple-browser-main)' --quit
