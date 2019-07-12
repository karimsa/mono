#!/bin/bash -e

cd "`dirname $0`/test-install"
wd="$PWD"

source "$wd/../helpers.sh"

rm -rf \
    "$wd/node_modules" \
    "$wd/preinstall-ran" \
    "$wd/postinstall-ran" \
    "$wd/packages/apple/node_modules" \
    "$wd/packages/apple/preinstall-ran" \
    "$wd/packages/apple/postinstall-ran" \
    "$wd/packages/baseball/node_modules" \
    "$wd/packages/baseball/preinstall-ran" \
    "$wd/packages/baseball/postinstall-ran"

not_exists "$wd/node_modules"
not_exists "$wd/preinstall-ran"
not_exists "$wd/postinstall-ran"
not_exists "$wd/packages/apple/node_modules"
not_exists "$wd/packages/apple/preinstall-ran"
not_exists "$wd/packages/apple/postinstall-ran"
not_exists "$wd/packages/baseball/node_modules"
not_exists "$wd/packages/baseball/preinstall-ran"
not_exists "$wd/packages/baseball/postinstall-ran"

CI=true "$wd/../../bootstrap.js"

exists "$wd/node_modules"
exists "$wd/preinstall-ran"
exists "$wd/postinstall-ran"
exists "$wd/packages/apple/node_modules"
exists "$wd/packages/apple/preinstall-ran"
exists "$wd/packages/apple/postinstall-ran"
exists "$wd/packages/baseball/node_modules"
exists "$wd/packages/baseball/preinstall-ran"
exists "$wd/packages/baseball/postinstall-ran"
