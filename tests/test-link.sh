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

"$wd/../../mono.sh" link

exists "$wd/packages/a/node_modules/@a/b"
exists "$wd/packages/b/node_modules/@a/a"

# C should not be linked to anything, since it has no name
not_exists "$wd/packages/a/node_modules/c"
not_exists "$wd/packages/b/node_modules/c"

# C should still have links to both other projects
exists "$wd/packages/c/node_modules/@a/b"
exists "$wd/packages/c/node_modules/@a/a"

"$wd/../../mono.sh" test
