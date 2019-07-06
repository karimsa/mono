#!/bin/bash
set -e
set -o pipefail

## mono.sh
## Monorepo manager.
##
## Copyright (C) 2019-present Karim Alibhai. All rights reserved.

if ! test -e "packages"; then
    echo "No directory named 'packages' found in $PWD - are you sure this is a monorepo?"
    exit 1
fi

function run_script() {
    script="$1"

    name="`cat package.json | jq -r .name`"
    if test "$name" = "null"; then
        name="`basename $PWD`"
    fi

    cmd="`cat package.json | jq -r .scripts.$script`"

    if test "$script" = "install"; then
        cmd="npm install"
    fi
    if test "$cmd" = "null"; then
        return
    fi

    enable_fg_color "27"
    echo -en "$name "
    disable_color

    enable_fg_color "10"
    echo -en "($script)"
    disable_color

    enable_fg_color "27"
    echo -en "> "
    disable_color

    enable_fg_color "13"
    echo -e "$cmd"
    disable_color

    bash -c "$cmd"
}

function enable_fg_color() {
    printf "\e[38;5;$1m"
}

function disable_color() {
    printf "\e[0m"
}

function list_packages() {
    if test "`jq -r .mono.packages package.json`" = "null"; then
        ls -1F packages | grep '/' | cut -d\/ -f1
    else
        jq -r '.mono.packages[]' package.json
    fi
}

command="$1"
if test -z "$command"; then
    command="install"
else
    shift
fi

jq="$PWD/jq/linux64"
if uname -a | grep Darwin &>/dev/null; then
    jq="$PWD/jq/macos"
fi

if ! test -e "./package.json"; then
    echo "{}" > package.json
fi

if test "$command" = "start"; then
    children=""

    for dir in `list_packages`; do
        cd "packages/$dir"
        name="`cat package.json | jq -r .name`"
        if test "$name" = "null"; then
            name="$dir"
        fi

        npm start 2>&1 | sed "s/^/[$name]: /" & children="$!"
        cd ../..
    done

    wait
    kill -9 "$children" &>/dev/null || true
elif test "$command" = "install" || test "$command" = "i" || test "$command" = "test" || test "$command" = "run"; then
    args=""
    if test "$command" = "run" || test "$command" = "test"; then
        if test "$command" = "run" && test "$#" = "0"; then
            echo "Please specify which script to run"
            exit 1
        fi

        if test "$command" = "run"; then
            command="$1"
            shift
        else
            command="test"
        fi

        if test "$#" -gt "0"; then
            if test "$1" = "--"; then
                shift
                args="$@"
            else
                echo "Unknown argument passed: $1 - can only take one argument"
                exit 1
            fi
        fi
    fi

    run_script "pre$command"
    
    if test "$command" != "test"; then
        run_script "$command"
    fi

    for dir in `list_packages`; do
        cd "packages/$dir"
        
        run_script "pre$command"
        run_script "$command"
        run_script "post$command"

        cd ../..
    done

    run_script "post$command"
else
    echo "Unknown command: $command"
    exit 1
fi
