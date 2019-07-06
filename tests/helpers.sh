#!/bin/bash -e

function print_err() {
    if test -z "$2"; then
        echo "$1"
    else
        echo "$1 - $2"
    fi
    echo ""
    exit 1
}

function exists() {
    if ! test -e "$1"; then
        print_err "Expected file/directory to exist, but did not find it: $1" "$2"
    fi
}

function not_exists() {
    if test -e "$1"; then
        echo "$1:"
        ls -lh "`dirname $1`"

        print_err "Did not expect file/directory to exist: $1" "$2"
    fi
}
