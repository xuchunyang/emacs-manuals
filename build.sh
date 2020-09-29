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
        git clone 'git://git.sv.gnu.org/emacs.git'
    fi
}

config() {
    cd "$SRC"
    # https://lists.gnu.org/archive/html/help-gnu-emacs/2017-05/msg00073.html
    git clean -xf
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

    # Fake (dir) node, just redirect to index.
    cp -r "$ROOT"/dir "$output"
    

    cd "$SRC"/doc/lispref
    make -e HTML_OPTS="--html --css-ref=./manual.css" elisp.html
    mv elisp.html "$output"/elisp
    cp "$CSS" "$output"/elisp

    cd "$SRC"/doc/emacs
    make -e HTML_OPTS="--html --css-ref=./manual.css" emacs.html
    mv emacs.html "$output"/emacs
    cp "$CSS" "$output"/emacs

    if [ "$version" != "24.3" ] ; then
        cd "$SRC"/doc/misc
        make -e HTML_OPTS="--html --no-split --css-ref=./manual.css" html
        mkdir "$output"/misc
        mv *.html "$output"/misc
        cp "$ROOT"/misc-index.html "$output"/misc/index.html
        cp "$CSS" "$output"/misc
    fi
}

download

build master
build 27.1
build 26.3
build 26.2
build 26.1
build 25.3
build 25.2
build 25.1
build 24.5
build 24.4
build 24.3

cp "$ROOT"/index.html "$DIST"
