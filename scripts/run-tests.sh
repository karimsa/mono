#!/bin/bash -e

cd "$(dirname $0)/.."

for test in tests/test-*.sh; do
    log="$(mktemp)"
    if $test &>$log; then
        echo "${test}: ok"
    else
        echo "${test}: not ok" >&2
        echo "" >&2
        cat $log >&2
        exit 1
    fi
done
