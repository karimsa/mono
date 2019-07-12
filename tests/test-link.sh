#!/bin/bash -e

cd "`dirname $0`/test-link"
wd="$PWD"

source "$wd/../helpers.sh"

rm -rf \
    "$wd/packages/a/node_modules" \
    "$wd/packages/b/node_modules"

not_exists "$wd/packages/a/node_modules"
not_exists "$wd/packages/b/node_modules"
not_exists "$wd/packages/b/node_modules"

"$wd/../../bootstrap.js" link
"$wd/../../bootstrap.js" test
