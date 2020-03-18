#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

ROOT=$PWD
SRC=$ROOT/emacs
DIST=$ROOT/dist
CSS=$ROOT/manual.css

download() {
    if test ! -d "$SRC"; then
        cd "$ROOT"
        git clone 'https://github.com/emacs-mirror/emacs.git'
    fi
}

config() {
    cd "$SRC"
    make distclean
    ./autogen.sh
    ./configure --with-x-toolkit=no --without-x --without-all
}

build() {
    cd "$SRC"
    local version=$1
    if [ "$version" = master ]; then
        git checkout master
    else
        git checkout "emacs-$version"
    fi

    config

    local output=$DIST/$version/
    mkdir -p "$output"

    cd "$SRC"/doc/lispref
    make -e HTML_OPTS="--html --css-ref=./manual.css" elisp.html
    mv elisp.html "$output"/elisp
    cp "$CSS" "$output"/elisp

    cd "$SRC"/doc/emacs
    make -e HTML_OPTS="--html --css-ref=./manual.css" emacs.html
    mv emacs.html "$output"/emacs
    cp "$CSS" "$output"/emacs
}

download

build master
build 26.3
build 26.2
build 26.1
build 25.3
build 25.2
build 25.1
build 24.5
build 24.4
build 24.3

