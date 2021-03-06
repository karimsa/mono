#!/bin/bash -e

cd "`dirname $0`/test-test"
wd="$PWD"

source "$wd/../helpers.sh"

rm -rf \
    "$wd/pretest-ran" \
    "$wd/test-ran" \
    "$wd/posttest-ran" \
    "$wd/packages/apple/pretest-ran" \
    "$wd/packages/apple/test-ran" \
    "$wd/packages/apple/posttest-ran" \
    "$wd/packages/baseball/pretest-ran" \
    "$wd/packages/baseball/test-ran" \
    "$wd/packages/baseball/posttest-ran"

not_exists "$wd/pretest-ran"
not_exists "$wd/test-ran"
not_exists "$wd/posttest-ran"
not_exists "$wd/packages/apple/pretest-ran"
not_exists "$wd/packages/apple/test-ran"
not_exists "$wd/packages/apple/posttest-ran"
not_exists "$wd/packages/baseball/pretest-ran"
not_exists "$wd/packages/baseball/test-ran"
not_exists "$wd/packages/baseball/posttest-ran"

"$wd/../../mono.sh" "test"

exists "$wd/pretest-ran"
exists "$wd/test-ran"
exists "$wd/posttest-ran"
exists "$wd/packages/apple/pretest-ran"
exists "$wd/packages/apple/test-ran"
exists "$wd/packages/apple/posttest-ran"
exists "$wd/packages/baseball/pretest-ran"
exists "$wd/packages/baseball/test-ran"
exists "$wd/packages/baseball/posttest-ran"
