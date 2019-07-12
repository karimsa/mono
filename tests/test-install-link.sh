#!/bin/bash -e

cd "`dirname $0`/test-install-link"
wd="$PWD"

source "$wd/../helpers.sh"

rm -rf \
    "$wd/node_modules" \
    "$wd/preinstall-ran" \
    "$wd/postinstall-ran" \
    "$wd/packages/a/node_modules" \
    "$wd/packages/a/preinstall-ran" \
    "$wd/packages/a/postinstall-ran" \
    "$wd/packages/b/node_modules" \
    "$wd/packages/b/preinstall-ran" \
    "$wd/packages/b/postinstall-ran"

not_exists "$wd/node_modules"
not_exists "$wd/preinstall-ran"
not_exists "$wd/postinstall-ran"
not_exists "$wd/packages/a/node_modules"
not_exists "$wd/packages/a/preinstall-ran"
not_exists "$wd/packages/a/postinstall-ran"
not_exists "$wd/packages/b/node_modules"
not_exists "$wd/packages/b/preinstall-ran"
not_exists "$wd/packages/b/postinstall-ran"

CI=false "$wd/../../bootstrap.js"

exists "$wd/node_modules"
exists "$wd/preinstall-ran"
exists "$wd/postinstall-ran"
exists "$wd/packages/a/node_modules"
exists "$wd/packages/a/preinstall-ran"
exists "$wd/packages/a/postinstall-ran"
exists "$wd/packages/b/node_modules"
exists "$wd/packages/b/preinstall-ran"
exists "$wd/packages/b/postinstall-ran"

"$wd/../../bootstrap.js" test
