#!/bin/bash

# start debugging/tracing commands, -e - exit if command returns error (non-zero status)
set -e

# Update paths in bower_components
echo 'gulp clean_bower'
gulp clean_bower

# cleanup in case of multiple runs
rm -rf ./app/bower_components/uqlibrary-computers/node_modules/
rm -rf ./app/bower_components/uqlibrary-hours/node_modules/
rm -rf ./app/bower_components/uqlibrary-papercut/node_modules/
rm -rf ./app/bower_components/uqlibrary-research/node_modules/

# because we are supplying components from npm rather than bower, we have to make sure they are available :(
mkdir -p ./app/bower_components/uqlibrary-computers/node_modules/lodash/
cp ./node_modules/lodash/lodash.min.js ./app/bower_components/uqlibrary-computers/node_modules/lodash/lodash.min.js

mkdir -p ./app/bower_components/uqlibrary-hours/node_modules/lodash/
cp ./node_modules/lodash/lodash.min.js  ./app/bower_components/uqlibrary-hours/node_modules/lodash/lodash.min.js
mkdir -p ./app/bower_components/uqlibrary-hours/node_modules/moment/
cp ./node_modules/moment/moment.js  ./app/bower_components/uqlibrary-hours/node_modules/moment/moment.js

mkdir -p ./app/bower_components/uqlibrary-papercut/node_modules/moment/
cp ./node_modules/moment/moment.js  ./app/bower_components/uqlibrary-papercut/node_modules/moment/moment.js

mkdir -p ./app/bower_components/uqlibrary-research/node_modules/moment/
cp ./node_modules/moment/moment.js  ./app/bower_components/uqlibrary-research/node_modules/moment/moment.js

