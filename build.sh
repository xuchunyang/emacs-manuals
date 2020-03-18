#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

ROOT=$PWD
SRC=$ROOT/emacs
DIST=$ROOT/dist

download() {
    if test ! -d "$SRC"; then
        cd "$ROOT"
        git clone 'https://github.com/emacs-mirror/emacs.git'
    fi
}

config() {
    cd "$SRC"
    ./autogen.sh && ./configure --without-all
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
    make -e HTML_OPTS="--html --css-ref=/manual.css" elisp.html
    mv elisp.html "$output"/elisp

    cd "$SRC"/doc/emacs
    make -e HTML_OPTS="--html --css-ref=/manual.css" emacs.html
    mv emacs.html "$output"/emacs
}

build master
build 26.3

ls -R "$DIST"
