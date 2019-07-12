#!/bin/bash
set -e
set -o pipefail

cd "`dirname $0`/test-npm"
wd="$PWD"

source "$wd/../helpers.sh"

rm -rf \
    "./node_modules"

not_exists "node_modules"

# simulate an `npm install`
mkdir -p node_modules/{.bin,mono}
cp -R $wd/../../{jq,*.sh,*.js,package*.json} "node_modules/mono/"
ln -s "$PWD/node_modules/mono/`jq -r .bin.mono "$wd/../../package.json"`" "node_modules/.bin/mono"
chmod +x "node_modules/.bin/mono"

ls -lha node_modules/.bin

# This runs the link & not the binary itself, which should be
# a good test to see if the link can still figure out its original
# mono directory to find jq
"./node_modules/.bin/mono" test
