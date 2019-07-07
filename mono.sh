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
    enable_echo="$2"

    name=""
    cmd=""

    if test -e "package.json"; then
        name="`cat package.json | jq -r .name`"
        cmd="`cat package.json | jq -r .scripts.$script`"
    else
        return
    fi

    if test "$name" = "null"; then
        name="`basename $PWD`"
    fi

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

    if test "$enable_echo" = "true"; then
        istty="false"
        if [ -t 1 ]; then
            istty="true"
        fi

        bash -c "$cmd" 2>&1 | sed "s:^:`enable_fg_color 4 $istty`[$name]`disable_color $istty` :"
    else
        bash -c "$cmd"
    fi
}

function enable_fg_color() {
    if test "$2" = "true" || [ -t 1 ]; then
        printf "\e[38;5;$1m"
    fi
}

function disable_color() {
    if test "$1" = "true" || [ -t 1 ]; then
        printf "\e[0m"
    fi
}

function list_packages() {
    if test "`jq -r .mono.packages package.json`" = "null"; then
        ls -1F packages | grep '/' | cut -d\/ -f1
    else
        jq -r '.mono.packages[]' package.json
    fi
}

function create_pkg_links() {
    for outerPkg in `list_packages`; do
        if ! test -e "packages/$outerPkg/package.json"; then
            echo "Skipping linking '$outerPkg' - no package.json"
            continue
        fi

        outerPkgName="`jq -r .name packages/$outerPkg/package.json`"
        if test "$outerPkgName" = "null"; then
            echo "Skipping linking '$outerPkg' - no name in package.json"
            continue
        fi

        for innerPkg in `list_packages`; do
            if test "$outerPkg" != "$innerPkg"; then
                cd "packages/$innerPkg"

                echo "Linking: $outerPkgName into packages/$innerPkg/"
                mkdir -p "node_modules/$outerPkg"
                echo "module.exports = require('../../../$outerPkg')" > "node_modules/$outerPkg/index.js"

                cd ../..
            fi
        done
    done
}

command="$1"

if test -z "$command"; then
    if test -z "$CI"; then
        command="install"
    else
        command="ci"
    fi
else
    shift
fi

jq="$PWD/jq/linux64"
if uname -a | grep Darwin &>/dev/null; then
    jq="$PWD/jq/macos"
fi

if test "$command" = "start"; then
    children=""

    function kill_children() {
        echo "Stopping start processes: $children"
        trap - SIGINT
        kill -9 $children &>/dev/null || true
    }
    trap kill_children SIGINT

    run_script prestart

    for dir in `list_packages`; do
        cd "packages/$dir"
        run_script prestart
        run_script start true & children="$! $children"
        cd ../..
    done

    wait
elif test "$command" = "install" || test "$command" = "i" || test "$command" = "ci" || test "$command" = "test" || test "$command" = "run"; then
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

    if test "$command" = "install"; then
        create_pkg_links
    fi
elif test "$command" = "link"; then
    create_pkg_links
else
    echo "Unknown command: $command"
    exit 1
fi
