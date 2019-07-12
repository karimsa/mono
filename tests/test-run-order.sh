#!/bin/bash -e

cd "`dirname $0`/test-run-order"
wd="$PWD"

source "$wd/../helpers.sh"

rm -rf \
    "$wd/run-order"

not_exists "$wd/run-order"

"$wd/../../bootstrap.js" run build

exists "$wd/run-order"

order="`cat $wd/run-order | tr -d '\n'`"
if test "$order" != "cba"; then
    print_err "Expected execution order C-B-A, but got: $order"
fi
