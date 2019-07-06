#!/bin/bash -e

cd "`dirname $0`/test-start"
wd="$PWD"

source "$wd/../helpers.sh"

log="`mktemp`"

function printlog() {
    echo '======== start output log ========'
    cat $log
    echo '========  end output log  ========'
    echo
}

if ! "$wd/../../mono.sh" "start" &> "$log"; then
    printlog
    print_err "Failed to run: mono start"
fi

if ! fgrep "[@a/a] hello from a" "$log" >/dev/null; then
    printlog
    print_err "Expected to find '[a]: hello from a' in logfile"
elif ! fgrep "[@a/b] hello from b" "$log" >/dev/null; then
    printlog
    print_err "Expected to find '[b]: hello from b' in logfile"
fi
