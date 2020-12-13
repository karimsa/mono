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

monoLocation="${MONO_DIRNAME}"

if test -z `readlink $0`; then
    monoLocation="`dirname $0`"
else
    prevPWD="$PWD"
    linkLoc="`readlink $0`"

    cd "`dirname $0`"
    cd "`dirname ${linkLoc}`"

    monoLocation="$PWD"
    cd $prevPWD
fi

if test -z "$monoLocation"; then
    echo "Failed to determine location of mono"
    exit 1
fi

jq="$monoLocation/jq/linux64/jq"
if uname -a | grep Darwin &>/dev/null; then
    jq="$monoLocation/jq/macos/jq"
fi

echo "Running @karimsa/mono v`$jq -r .version "${monoLocation}/package.json"`"

# patch for ensuring that local binaries are always available
export PATH="$PATH:$PWD/node_modules/.bin:./node_modules/.bin"

function run_script() {
    script="$1"
    enable_echo="$2"
    color_offset="$3"

    name=""
    cmd=""

    # Map hooks for `npm ci` to `npm install`
    if test "$script" = "preci"; then
        script="preinstall"
    elif test "$script" = "postci"; then
        script="postinstall"
    fi

    if test -e "package.json"; then
        name="`cat package.json | $jq -r .name`"
        cmd="`cat package.json | $jq -r .scripts['$script']`"
    else
        return 0
    fi

    if test "$script" = "install"; then
        cmd="npm install --no-audit"
    elif test "$script" = "ci"; then
        cmd="npm ci"

        # Patch package.json because `npm ci` craps out
        # if you don't
        if test "$name" = "null"; then
            $jq '.name = ""' package.json > package.new.json
            mv package.new.json package.json
        fi
    fi
    if test "$cmd" = "null"; then
        return 0
    fi

    if test "$name" = "null" || test -z "$name"; then
        name="`basename $PWD`"
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

        bash -c "$cmd" 2>&1 | sed "s:^:`enable_fg_color $[1+$color_offset] $istty`[$name]`disable_color $istty` :"
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
    if ! test -e "package.json" || test "`$jq -r .mono.packages package.json`" = "null"; then
        ls -1F packages | grep '/' | cut -d\/ -f1
    else
        $jq -r '.mono.packages[]' package.json
    fi
}

function create_pkg_links() {
    for outerPkg in `list_packages`; do
        if ! test -e "packages/$outerPkg/package.json"; then
            echo "Skipping linking '$outerPkg' - no package.json"
            continue
        fi

        outerPkgName="`$jq -r .name packages/$outerPkg/package.json`"
        if test "$outerPkgName" = "null"; then
            echo "Skipping linking '$outerPkg' - no name in package.json"
            continue
        fi

        for innerPkg in `list_packages`; do
            if test "$outerPkg" != "$innerPkg"; then
                cd "packages/$innerPkg"

                echo "Linking: $outerPkgName into packages/$innerPkg/"
                mkdir -p "node_modules/$outerPkgName"

                if test "${outerPkgName:0:1}" = "@"; then
                    # Scoped path: (scope parent) > node_modules > (inner src) > (packages)
                    echo "module.exports = require('../../../../$outerPkg')" > "node_modules/$outerPkgName/index.js"
                else
                    # Non-scoped path: node_modules > (inner src) > (packages)
                    echo "module.exports = require('../../../$outerPkg')" > "node_modules/$outerPkgName/index.js"
                fi

                cd ../..
            fi
        done
    done
}

command="$1"

if test -z "$command"; then
    if test "$CI" = "true"; then
        command="ci"
    else
        command="install"
    fi
else
    shift
fi

if test "$command" = "start"; then
    childlist="`mktemp`"

    function kill_children() {
        children="`cat $childlist`"
        echo "Stopping start processes: $children"
        trap - SIGINT
        kill -9 $children &>/dev/null || true
    }
    trap kill_children SIGINT

    run_script prestart

    numPackages=0
    for dir in `list_packages`; do
        cd "packages/$dir"
        run_script prestart
        run_script start true "$numPackages" & echo "$!" >> "$childlist"
        cd ../..
        numPackages="$[1+$numPackages]"
    done

    while kill -0 `cat $childlist` &>/dev/null; do
        :
    done
    rm -f $childlist
elif test "$command" = "install" || test "$command" = "ci"; then
    run_script "$command"

    for dir in `list_packages`; do
        cd "packages/$dir"
        run_script "$command"

        cd ../..
    done

    create_pkg_links
elif test "$command" = "test" || test "$command" = "run"; then
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
    run_script "$command"

    for dir in `list_packages`; do
        cd "packages/$dir"

        run_script "pre$command"
        run_script "$command"
        run_script "post$command"

        cd ../..
    done

    run_script "post$command"
elif test "$command" = "link"; then
    create_pkg_links
else
    echo "Unknown command: $command"
    exit 1
fi
